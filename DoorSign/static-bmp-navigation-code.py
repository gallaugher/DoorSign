"""
Put this code on a properly configured PyPortal. You can buy one
from Adafruit:
https://www.adafruit.com/product/4116

Special thanks to John for posting touch-screen code he used in his
PyPortal app launcher:
https://furcean.com/2019/03/21/pyportal-app-launcher/

And John Park & the Adafruit crew for the PyPortal Weather Station
demo, which was helpful in understanding JSON parsing.
https://learn.adafruit.com/pyportal-weather-station/overview

This version was a demo showing how I could hard-code click spots on .bmps
There is no iOS app integration with this code, nor is anything fetched over the
Internet. I am NOT a python programmer, so this code is really raw, hasn't been refactored, or
cleaned up in any way. Sorry I've been so busy, but let me know if it's
helpful & also if you've got suggestions (esp. for the other code file
that is the one connected to the iOS app & Cloud Firestore).
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

DATA_SOURCE = "https://firestore.googleapis.com/v1beta1/projects/doorsign-3557c/databases/(default)/documents/events/"   # pylint: disable=line-too-long
DATA_LOCATION = [0, "documents"]

pyportal = PyPortal(url=DATA_SOURCE,
                    default_bg=cwd+"/home_screen.bmp",)

events_list=[]

# These pins are used as both analog and digital! XL, XR and YU must be analog
# and digital capable. YD just need to be digital
ts = adafruit_touchscreen.Touchscreen(board.TOUCH_XL, board.TOUCH_XR,
                                      board.TOUCH_YD, board.TOUCH_YU,
                                      calibration=((5200, 59000), (5800, 57000)),
                                      size=(320, 240))
numOfEvents = 3
current_event = 0

p_list = []
# This will be the first screen shown. Make sure you have
# a 360 x 240 16 bit, bmp file. JPEG, PNG, GIFs wont work.
current_image = "home_screen.bmp"

main_buttons = [dict(left=0, top=180, right=80, bottom=240),    # courses
            dict(left=80, top=180, right=160, bottom=240),   # contact
            dict(left=160, top=180, right=240, bottom=240),  # news
            dict(left=240, top=180, right=360, bottom=240),   # back - on all but home_screen.bmp
            dict(left=0, top=80, right=55, bottom=130), # left arrow  - only on news
            dict(left=265, top=80, right=320, bottom=130)] # right arrow  - only on news

def get_news():
    global events_list
    print(">>> GET NEWS FETCH call on PyPortal")
    try:
        value = pyportal.fetch()
        events_json=json.loads(value)
        events_list=events_json["documents"]
        print("There are", len(events_list), "events in Cloud Firestore."))
    except (ValueError, RuntimeError) as e:
        print("Some error occured, retrying! -", e)

def print_current_event():
        print("*** PRINTING CURRENT EVENT ", current_event, " ***")
        print(events_list[current_event]["fields"]["eventName"]["stringValue"])
        print(events_list[current_event]["fields"]["dateString"]["stringValue"])
        print(events_list[current_event]["fields"]["timeString"]["stringValue"])
        print(events_list[current_event]["fields"]["eventLocation"]["stringValue"])
        print(events_list[current_event]["fields"]["eventDescription"]["stringValue"])
        
        print(events_list[current_event]["fields"]["fontSize"]["integerValue"])
        print(events_list[current_event]["fields"]["startInterval"]["doubleValue"])
        print("\") # new line
        
        # line below is useful if you're using CloudFirestore w/o the app & want to insert
        # new line commands by typing \n. Firestore converts these to \\n, but the replace
        # below will remove the extra \ so that linefeeds show up.
        # event_details = events_list[current_event]["fields"]["details"]["stringValue"].replace("\\n","\n")
        print(event_details)

def touch_in_button(t, b):
    in_horizontal = b['left'] <= t[0] <= b['right']
    in_vertical = b['top'] <= t[1] <= b['bottom']
      # returns True if point t is in main_button's left, top, right, bottom rectangle
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
        pyportal.set_background('contact.bmp')
        current_image = 'contact.bmp'
    elif button_number == 2:
        print("*** News Touched ***")
        get_news()
        pyportal.set_background('events_pressed.bmp')
        # sleap to show press for a bit before updating
        time.sleep(.5)
        print_current_event()

          # In basic version w/o Firebase, events are named starting with event0
        current_image = 'event' + str(current_event) + '.bmp'
        pyportal.set_background(current_image)
        print("current_image = ", current_image)
    elif button_number == 3 and current_image != 'home_screen.bmp':
        print("<= Back Touched <=")
        pyportal.set_background('home_screen.bmp')
        current_image = 'home_screen.bmp'
              # TODO - line below won't work if we're creating images with each page
    elif button_number == 4 and current_image.startswith('event'):
        print("<<< BWD Button Touched <<<")
        global current_event # TODO - do I even need to declare this since it was declared earlier?
        current_event = current_event - 1
        if current_event < 0:
            current_event = numOfEvents-1
        current_image = 'event' + str(current_event) +'.bmp'
        pyportal.set_background(current_image)
        print_current_event()
              # TODO - line below won't work if we're creating images with each page
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

