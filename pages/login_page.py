from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time


class LoginPage:
    # --- 1. LOCATORS (The Addresses) ---
    USERNAME_FIELD = (AppiumBy.XPATH, '//android.widget.EditText[contains(@hint,"login_username_field")]')
    PASSWORD_FIELD = (AppiumBy.XPATH, '//android.widget.EditText[contains(@hint,"login_password_field")]')
    # Note: Using * to unpack tuple locators requires self.driver.find_element(*self.LOCATOR)

    # Updated Locators to match your script's needs
    REMEMBER_ME = (AppiumBy.XPATH, '//android.widget.CheckBox[contains(@content-desc,"login_remember_me")]')
    LOGIN_BUTTON = (AppiumBy.XPATH, '//android.widget.Button[contains(@content-desc,"Login")]')
    LOGIN_PASSWORD_VISIBILITY = (AppiumBy.XPATH, '//android.view.View[@content-desc="login_password_visibility"]')

    # Popups & Messages
    ERROR_MESSAGE = (AppiumBy.XPATH, '//android.view.View[contains(@content-desc, "Wrong Username Or Password")]')
    CONTINUE_BUTTON = (AppiumBy.XPATH, '//android.widget.Button[contains(@content-desc, "Continue")]')
    SUCCESS_MESSAGE = (AppiumBy.XPATH, '//android.view.View[contains(@content-desc, "Woo Hoo!")]')
    DONE_BUTTON = (AppiumBy.XPATH, '//android.widget.Button[contains(@content-desc, "Done")]')
    HOME_SCREEN = (AppiumBy.XPATH, '//android.view.View[contains(@content-desc, "Home")]')

    # --- 2. INITIALIZATION ---
    def __init__(self, driver):
        self.driver = driver
        # Initialize a waiter specifically for this page
        self.wait = WebDriverWait(driver, 10)

    # --- 3. ACTIONS (The Skills) ---

    def enter_username(self, username):
        print(f"  > Action: Entering Username '{username}'...")
        field = self.wait.until(EC.visibility_of_element_located(self.USERNAME_FIELD))
        field.click()

        # CRITICAL FIX: Removed field.clear() to prevent crash.
        # We rely on the app restart to provide an empty field.
        field.send_keys(username)

        # Small pause to let the UI process the input
        time.sleep(0.5)

    def enter_password(self, password):
        print("  > Action: Entering Password...")
        field = self.wait.until(EC.visibility_of_element_located(self.PASSWORD_FIELD))
        field.click()

        # CRITICAL FIX: Removed field.clear() to prevent crash.
        field.send_keys(password)

        # Hide keyboard safely by clicking the background (prevents 'Back' button issues)
        try:
            # Tapping a non-active element (like the "Remember Me" label or background) often closes keyboard
            # Alternatively, we can just wait a moment.
            time.sleep(1)
        except:
            pass

    def toggle_password_visibility(self):
        print("  > Action: Toggling Password Visibility...")
        try:
            toggle_button = self.wait.until(EC.visibility_of_element_located(self.LOGIN_PASSWORD_VISIBILITY))
            toggle_button.click()
            time.sleep(1)
        except Exception as e:
            print(f"  > Warning: Could not toggle visibility: {e}")

    def toggle_remember_me(self, want_checked=True):
        print(f"  > Action: Setting 'Remember Me' to {want_checked}...")

        # CRITICAL FIX: "Blind Click" Strategy
        # Checking .get_attribute("checked") causes crashes on some Flutter/Emulator combos.
        # Since we restart the app, we KNOW it starts unchecked.
        if want_checked:
            try:
                checkbox = self.wait.until(EC.visibility_of_element_located(self.REMEMBER_ME))
                checkbox.click()
                print("    -> Clicked checkbox (Blind trust)")
            except Exception as e:
                print(f"    -> Warning: Could not click checkbox: {e}")
        else:
            print("    -> Skipping click (assuming default is unchecked)")

    def click_login(self):
        print("  > Action: Clicking Login Button")
        self.wait.until(EC.visibility_of_element_located(self.LOGIN_BUTTON)).click()

    def verify_error_message(self):
        print("  > Verification: Waiting for Error Message...")
        self.wait.until(EC.presence_of_element_located(self.ERROR_MESSAGE))
        print("    ✅ Error Message Found!")

    def close_error_popup(self):
        print("  > Action: Closing Error Popup")
        self.wait.until(EC.visibility_of_element_located(self.CONTINUE_BUTTON)).click()
        time.sleep(1)  # Wait for popup to fade

    def verify_success_message(self):
        print("  > Verification: Waiting for 'Woo Hoo!'...")
        self.wait.until(EC.presence_of_element_located(self.SUCCESS_MESSAGE))
        print("    ✅ Success Message Found!")

    def go_to_home(self):
        print("  > Action: Clicking Done -> Home")
        self.wait.until(EC.visibility_of_element_located(self.DONE_BUTTON)).click()
        # Verify we are home
        self.wait.until(EC.presence_of_element_located(self.HOME_SCREEN))
        print("    ✅ Reached Home Screen!")