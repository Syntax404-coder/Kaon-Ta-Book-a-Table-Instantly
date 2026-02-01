require "application_system_test_case"

class BookingFlowTest < ApplicationSystemTestCase
  test "complete booking and cancellation flow" do
    # Step 1: Visit homepage (redirects to login)
    visit root_path
    assert_text "Login"

    # Step 2: Sign up as new user - click the link in the form, not navbar
    click_link "Sign Up", match: :first
    fill_in "Name", with: "Test User"
    fill_in "Email", with: "testuser@example.com"
    fill_in "Password", with: "password123"
    fill_in "Password confirmation", with: "password123"
    click_button "Sign Up"

    assert_text "Logged in"

    # Step 3: Select a date (force tomorrow to ensure slots are available)
    tomorrow = 1.day.from_now.to_date
    tomorrow_text = tomorrow.strftime("%B %d, %Y")
    
    fill_in "date", with: tomorrow
    click_button "Check Availability"
    
    # Wait for the date header to change to tomorrow's date
    assert_text tomorrow_text
    
    first(:link, "Book Now").click
    
    # Wait for the next page to load
    assert_selector "input[name='guest_count']"
    
    # Capture the actual table we are booking by reading the URL
    uri = URI.parse(current_url)
    table_id = CGI.parse(uri.query)["table_id"].first
    table = Table.find(table_id)
    initial_seats = table.remaining_seats


    # Step 5: Complete booking with 2 guests
    assert_selector "input[value='Confirm Booking']"
    fill_in "guest_count", with: 2
    page.execute_script("document.querySelector('form').submit()")

    assert_text "Reservation confirmed"

    # Verify seats decremented
    table.reload
    assert_equal initial_seats - 2, table.remaining_seats

    # Step 6: Visit My Reservations
    visit my_reservations_path
    assert_selector "h1", text: "My Reservations"
    assert_selector "table tbody tr", minimum: 1

    # Step 7: Cancel the reservation
    seats_before_cancel = table.remaining_seats
    accept_confirm do
      click_button "Cancel"
    end

    assert_no_button "Cancel"

    # Verify seats restored
    table.reload
    assert_equal seats_before_cancel + 2, table.remaining_seats
  end
end
