from appium import webdriver
from appium.options.android import UiAutomator2Options
import time
import sys
import os
import datetime

# Add parent directory to path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from pages.login_page import LoginPage

# --- SETUP ---
options = UiAutomator2Options()
options.platform_name = "Android"
options.automation_name = "UiAutomator2"
options.device_name = "emulator-5554"

# Define the package name explicitly for the restart logic
APP_PACKAGE = "com.example.studymate"

print("Connecting to Appium Server...")
driver = webdriver.Remote("http://127.0.0.1:4723", options=options)

try:
    print("\n--- Starting Page Object Model Test ---")
    login_page = LoginPage(driver)

    # Initial setup for first run
    login_page.toggle_password_visibility()

    # ==============================
    # TEST CASE 1: NEGATIVE TEST
    # ==============================
    # print("\n[Test 1] Negative Login Scenario")
    # login_page.enter_username("Aly")
    # login_page.enter_password("WrongPass123")
    # login_page.toggle_remember_me(want_checked=True)
    # login_page.click_login()
    #
    # login_page.verify_error_message()
    # login_page.close_error_popup()
    #
    # # ==========================================
    # # 🔄 FIX: RESTART APP BEFORE NEXT TEST
    # # ==========================================
    # print("\n🔄 Restarting App for Test 2...")
    # # This prevents the need to use .clear() which causes crashes on Flutter/Emulators
    # driver.terminate_app(APP_PACKAGE)
    # time.sleep(1)
    # driver.activate_app(APP_PACKAGE)
    # time.sleep(3)  # Wait for splash screen to finish
    #
    # # Re-initialize Page Object (optional, but good practice)
    # login_page = LoginPage(driver)
    # print("✅ App Restarted Successfully")

    # ==============================
    # TEST CASE 2: POSITIVE TEST
    # ==============================
    print("\n[Test 2] Positive Login Scenario")
    login_page.enter_username("Aly")
    login_page.enter_password("Ialy24405")

    # Note: We don't toggle visibility again because the app reset to default (hidden)
    # login_page.toggle_password_visibility()

    login_page.toggle_remember_me(want_checked=True)
    login_page.click_login()

    login_page.verify_success_message()
    # login_page.go_to_home() # Uncomment if you have this method ready

    print("\n🎉 ALL TESTS PASSED SUCCESSFULLY!")

except Exception as e:
    print(f"\n❌ TEST FAILED: {e}")

    # --- 1. PREPARE DIRECTORIES ---
    base_error_dir = "error_logs"
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    current_error_folder_name = f"error_{timestamp}"
    full_path = os.path.join(base_error_dir, current_error_folder_name)
    os.makedirs(full_path, exist_ok=True)

    # --- 2. SAVE SCREENSHOT ---
    try:
        screenshot_path = os.path.join(full_path, "screenshot.png")
        driver.save_screenshot(screenshot_path)
    except Exception as s_e:
        print(f"  > Could not save screenshot: {s_e}")

    # --- 3. SAVE LOG FILE ---
    log_path = os.path.join(full_path, "error_log.txt")
    with open(log_path, "w", encoding="utf-8") as f:
        f.write(f"Timestamp: {timestamp}\n")
        f.write(f"Error Message:\n{str(e)}\n")

    print(f"\n📸 Evidence saved in: {full_path}")

finally:
    print("\nClosing app...")
    time.sleep(2)
    driver.quit()