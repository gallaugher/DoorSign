"""
Put this code on a properly configured PyPortal. You can buy one
from Adafruit:
https://www.adafruit.com/product/4116
"""
import time
import board
import json
import adafruit_touchscreen
from adafruit_pyportal import PyPortal

# the current working directory (where this file is)
cwd = ("/"+__file__).rsplit('/', 1)[0]
# Initialize the pyportal object and let us know what data to fetch and where
# to display it

DATA_SOURCE = "https://firestore.googleapis.com/v1beta1/projects/door-sign-da583/databases/(default)/documents/events/"   # pylint: disable=line-too-long
DATA_LOCATION = [0, "documents"]

pyportal = PyPortal(url=DATA_SOURCE,
                    default_bg=cwd+"/BC_Background.bmp",)

events_list=[]

"""
pyportal = PyPortal(url=DATA_SOURCE,
                    json_path=DATA_LOCATION,
                    default_bg=cwd+"/BC_Background.bmp",)
"""

"""
pyportal = PyPortal(url='',
                    default_bg=cwd+"/BC_Background.bmp",)
"""

# These pins are used as both analog and digital! XL, XR and YU must be analog
# and digital capable. YD just need to be digital
ts = adafruit_touchscreen.Touchscreen(board.TOUCH_XL, board.TOUCH_XR,
                                      board.TOUCH_YD, board.TOUCH_YU,
                                      calibration=((5200, 59000), (5800, 57000)),
                                      size=(320, 240))
numOfEvents = 3
current_event = 0

# track the last value so we can play a sound when it updates
last_value = 0
p_list = []
current_image = "BC_Background.bmp"

main_buttons = [dict(left=0, top=180, right=80, bottom=240),    # courses
            dict(left=80, top=180, right=160, bottom=240),   # contact
            dict(left=160, top=180, right=240, bottom=240),  # news
            dict(left=240, top=180, right=360, bottom=240),   # back
            dict(left=0, top=80, right=55, bottom=130), # left arrow
            dict(left=265, top=80, right=320, bottom=130)] # right arrow

return_buttons = [dict(left=240, top=180, right=360, bottom=240)] # only one back button

arrow_butons = [dict(left=0, top=80, right=35, bottom=125),
            dict(left=280, top=90, right=360, bottom=125)]

def get_news():
    global events_list
    print(">>> GET NEWS FETCH call on PyPortal")
    try:
        value = pyportal.fetch()
        events_json=json.loads(value)
        events_list=events_json["documents"]
    except (ValueError, RuntimeError) as e:
        print("Some error occured, retrying! -", e)

def print_current_event():
        print("*** PRINTING CURRENT EVENT ", current_event, " ***")
        print(events_list[current_event]["fields"]["name"]["stringValue"])
        event_details = events_list[current_event]["fields"]["details"]["stringValue"].replace("\\n","\n")
        print(event_details)

def touch_in_button(t, b):
    in_horizontal = b['left'] <= t[0] <= b['right']
    in_vertical = b['top'] <= t[1] <= b['bottom']
    return in_horizontal and in_vertical

def handle_press_action(button_number):
    global current_event
    global current_image
    print("IN handle_press_action and button_number =", button_number)
    print("current_image =", current_image)
    print("current_image.startswith('event') =", current_image.startswith('event'))
    if button_number == 0:
        print("* Courses Touched *")
        pyportal.set_background('courses_pressed.bmp')
        # sleap to show press for a bit before updating
        time.sleep(.5)
        pyportal.set_background('courses.bmp')
        current_image = 'courses.bmp'
    elif button_number == 1:
        print("** Contact Touched *")
        pyportal.set_background('contact_pressed.bmp')
        # sleap to show press for a bit before updating
        time.sleep(.5)
        pyportal.set_background('gold-contact.bmp')
        current_image = 'gold-contact.bmp'
    elif button_number == 2:
        print("*** News Touched ***")
        get_news()
        pyportal.set_background('news_pressed.bmp')
        # sleap to show press for a bit before updating
        time.sleep(.5)
        print_current_event()
        current_image = 'event' + str(current_event) + '.bmp'
        pyportal.set_background(current_image)
        print("current_image = ", current_image)
    elif button_number == 3 and current_image != 'BC_Background.bmp':
        print("<= Back Touched <=")
        pyportal.set_background('BC_Background.bmp')
        current_image = 'BC_Background.bmp'
    elif button_number == 4 and current_image.startswith('event'):
        print("<<< BWD Button Touched <<<")
        global current_event
        current_event = current_event - 1
        if current_event < 0:
            current_event = numOfEvents-1
        current_image = 'event' + str(current_event) +'.bmp'
        pyportal.set_background(current_image)
        print_current_event()
    elif button_number == 5 and current_image.startswith('event'):
        print(">>> FWD Button Touched >>>")
        current_event = current_event + 1
        if current_event == numOfEvents:
            current_event = 0
        print("current_image = ", current_image, "current_event = ", current_event)
        current_image = 'event' + str(current_event) +'.bmp'
        pyportal.set_background(current_image)
        print_current_event()

def handle_start_press(point):
    for button_index in range(len(main_buttons)):
        b = main_buttons[button_index]
        if touch_in_button(point, b):
            current_screen = str(button_index)
            print("Button", button_index, "pressed")
            handle_press_action(button_index)
            break

while True:
    p = ts.touch_point

    if p:
      print("p = ", p)
      # append each touch connection to a list
      # I had an issue with the first touch detected not being accurate
      p_list.append(p)

      #affter three trouch detections have occured.
      if len(p_list) == 3:

        #discard the first touch detection and average the other two get the x,y of the touch
        x = (p_list[1][0]+p_list[2][0])/2
        y = (p_list[1][1]+p_list[2][1])/2
        print("!!! TOUCH DETECTED: ", x,y)
        current_touch_point = (x,y)
        print("current_image = ", current_image)
        handle_start_press((x,y))

        # sleap to avoid pressing two buttons on accident
        time.sleep(.5)
        # clear p
        p_list = []
"""
        # Get json data
        print("ABOUT TO CALL PyPortal")
        try:
            value = pyportal.fetch()
            events_json=json.loads(value)
            events_list=events_json["documents"]
            print(events_list[2]["fields"]["name"]["stringValue"])
            print(events_list[2]["fields"]["details"]["stringValue"])
            event_details = events_list[2]["fields"]["details"]["stringValue"].replace("\\n","\n")
            print(event_details)
            # event_details = events_list[2]["fields"]["details"]["stringValue"].split()
            print("*** and now loop ***")
            for i in events_list:
                event_name=i["fields"]["name"]["stringValue"]
                print(type(event_name))
                print(event_name)

        except (ValueError, RuntimeError) as e:
            print("Some error occured, retrying! -", e)

"""
