from appium import webdriver
from appium.options.android import UiAutomator2Options
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time


# --- REUSABLE FUNCTION ---
def perform_login(driver, wait, username, password, want_remember_me=True):
    """
    Handles the interaction of entering credentials and clicking login.
    Uses 'Blind Clearing' to guarantee empty fields.
    """
    print(f"\n--- Attempting Login with User: {username} ---")

    # 0. Always hide keyboard first to see everything
    try:
        driver.hide_keyboard()
        time.sleep(1)  # Wait for layout to settle
    except:
        pass

    # 1. Find Elements (Using Smart Waits for ALL of them to prevent crashes)
    username_field = wait.until(EC.visibility_of_element_located(
        (AppiumBy.XPATH, '//android.widget.EditText[contains(@hint,"login_username_field")]')))

    # We use wait.until here too!
    password_field = wait.until(EC.visibility_of_element_located(
        (AppiumBy.XPATH, '//android.widget.EditText[contains(@hint,"login_password_field")]')))

    login_button = wait.until(EC.visibility_of_element_located(
        (AppiumBy.XPATH, '//android.widget.Button[contains(@content-desc,"Login")]')))

    # 2. Interact with Username
    print(f"  > Clearing and Typing Username: {username}")
    username_field.click()

    # --- BLIND CLEARING STRATEGY ---
    # 1. Try standard clear
    username_field.clear()
    # 2. Force delete 30 chars blindly (safer than reading text)
    driver.press_keycode(123)  # Move cursor to end (just in case)
    for _ in range(10):
        driver.press_keycode(67)  # Backspace
    # -------------------------------

    driver.switch_to.active_element.send_keys(username)

    # 3. Interact with Password
    print("  > Clearing and Typing Password...")
    password_field.click()

    # --- BLIND CLEARING PASSWORD ---
    password_field.clear()
    driver.press_keycode(123)  # Move cursor to end
    for _ in range(10):
        driver.press_keycode(67)
    # -------------------------------

    driver.switch_to.active_element.send_keys(password)

    # 4. Handle Keyboard
    try:
        driver.hide_keyboard()
    except:
        pass

    # 5. Smart 'Remember Me' Logic
    print("  > Checking 'Remember Me' Checkbox...")
    remember_me_checkbox = wait.until(EC.visibility_of_element_located(
        (AppiumBy.XPATH, '//android.widget.CheckBox[contains(@content-desc,"login_remember_me")]')))
    time.sleep(1)

    # Check state
    current_state_str = remember_me_checkbox.get_attribute("checked")
    is_currently_checked = current_state_str == "true"

    print(f"    [State Check] Current: {is_currently_checked} | Wanted: {want_remember_me}")

    if is_currently_checked != want_remember_me:
        print("    Action: Clicking to toggle!")
        remember_me_checkbox.click()
    else:
        print("    Action: Already correct. No click needed.")

    # 6. Click Login
    print("  > Clicking Login Button...")
    login_button.click()


# --- MAIN TEST SCRIPT ---
options = UiAutomator2Options()
options.platform_name = "Android"
options.automation_name = "UiAutomator2"
options.device_name = "emulator-5554"

print("Connecting to Appium Server...")
driver = webdriver.Remote("http://127.0.0.1:4723", options=options)
wait = WebDriverWait(driver, 10)

try:
    print("App launched!")

    # TEST CASE 1: NEGATIVE TEST
    # perform_login(driver, wait, "Aly", "WrongPass123", want_remember_me=True)

    # print("  > Waiting for Error Message...")
    # wait.until(EC.presence_of_element_located(
    #     (AppiumBy.XPATH, '//android.view.View[contains(@content-desc, "Wrong Username Or Password")]')))
    # print("✅ Test Passed: Error message displayed correctly!")

    # Close popup
    # continue_button = driver.find_element(AppiumBy.XPATH,
    #                                       '//android.widget.Button[contains(@content-desc, "Continue")]')
    # continue_button.click()
    # time.sleep(1)

    # TEST CASE 2: POSITIVE TEST
    perform_login(driver, wait, "Aly", "Ialy24405", want_remember_me=True)

    print("  > Waiting for Success Page...")
    wait.until(
        EC.presence_of_element_located((AppiumBy.XPATH, '//android.view.View[contains(@content-desc, "Woo Hoo!")]')))
    print("✅ Test Passed: Login Successful!")

    # Verify Home
    driver.find_element(AppiumBy.XPATH, '//android.widget.Button[contains(@content-desc, "Done")]').click()
    wait.until(EC.presence_of_element_located((AppiumBy.XPATH, '//android.view.View[contains(@content-desc, "Home")]')))
    print("✅ Test Passed: Reached Home Screen!")

except Exception as e:
    print(f"❌ Test Failed: {e}")

finally:
    print("Closing the app...")
    time.sleep(2)
    driver.quit()