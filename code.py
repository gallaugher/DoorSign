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

Super-raw, code, but it does show how you can access a Google
Cloud Firestore URL that can be updated via app, and use this
data to render a page for PyPortal. It's slow, this code
contains lots of old, unused garbage code from prior attempts,
but I wanted to share this quickly in case others are interested
in helping w/the project. I'm sure I can learn from others, as
I am NOT a Python programmer. If it's useful, or if you have
ideas, do let me know! @gallaugher on Twitter or
gallaugher.com & http://bit.ly/GallaugherYouTube
"""

import time
import board
import json
import adafruit_touchscreen
from adafruit_pyportal import PyPortal
from adafruit_button import Button
from adafruit_bitmap_font import bitmap_font
from adafruit_display_text.label import Label
"""
# TEMP so you don't need to keep making slow json call
elements_json = {
    "documents": [
        {
            "name": "projects/doorsign-3557c/databases/(default)/documents/elements/039E3E51-8E50-4F0F-B5F6-EE0F5C82DE9C",
            "fields": {
                "hierarchyLevel": {
                    "integerValue": "2"
                },
                "parentID": {
                    "stringValue": "262A785A-730B-48C1-8344-D2B84FF13062"
                },
                "elementName": {
                    "stringValue": "News"
                },
                "childrenIDs": {
                    "arrayValue": {}
                },
                "backgroundImageUUID": {
                    "stringValue": ""
                },
                "elementType": {
                    "stringValue": "Page"
                }
            },
            "createTime": "2019-04-26T02:46:53.305996Z",
            "updateTime": "2019-04-26T02:46:53.305996Z"
        },
        {
            "name": "projects/doorsign-3557c/databases/(default)/documents/elements/1A462259-EF86-4094-AA53-50CB73548F41",
            "fields": {
                "elementType": {
                    "stringValue": "Page"
                },
                "hierarchyLevel": {
                    "integerValue": "2"
                },
                "parentID": {
                    "stringValue": "262A785A-730B-48C1-8344-D2B84FF13062"
                },
                "elementName": {
                    "stringValue": "News"
                },
                "childrenIDs": {
                    "arrayValue": {}
                },
                "backgroundImageUUID": {
                    "stringValue": ""
                }
            },
            "createTime": "2019-04-26T02:46:43.138568Z",
            "updateTime": "2019-04-26T02:46:43.138568Z"
        },
        {
            "name": "projects/doorsign-3557c/databases/(default)/documents/elements/262A785A-730B-48C1-8344-D2B84FF13062",
            "fields": {
                "hierarchyLevel": {
                    "integerValue": "1"
                },
                "parentID": {
                    "stringValue": "f7JY7Ri8VUbHHmzsaXd8"
                },
                "elementName": {
                    "stringValue": "News"
                },
                "childrenIDs": {
                    "arrayValue": {
                        "values": [
                            {
                                "stringValue": "1A462259-EF86-4094-AA53-50CB73548F41"
                            },
                            {
                                "stringValue": "039E3E51-8E50-4F0F-B5F6-EE0F5C82DE9C"
                            },
                            {
                                "stringValue": "ADD4DB42-F8CB-41B2-9C4A-84FCA3EDBC22"
                            }
                        ]
                    }
                },
                "backgroundImageUUID": {
                    "stringValue": ""
                },
                "elementType": {
                    "stringValue": "Button"
                }
            },
            "createTime": "2019-04-26T02:46:42.971410Z",
            "updateTime": "2019-04-26T10:31:23.618376Z"
        },
        {
            "name": "projects/doorsign-3557c/databases/(default)/documents/elements/62B4C61B-F675-49CD-9363-DF320D57A705",
            "fields": {
                "hierarchyLevel": {
                    "integerValue": "1"
                },
                "parentID": {
                    "stringValue": "f7JY7Ri8VUbHHmzsaXd8"
                },
                "elementName": {
                    "stringValue": "Courese"
                },
                "childrenIDs": {
                    "arrayValue": {
                        "values": [
                            {
                                "stringValue": "CDA81FEB-91C0-4980-B85F-97D6E14F3859"
                            }
                        ]
                    }
                },
                "backgroundImageUUID": {
                    "stringValue": ""
                },
                "elementType": {
                    "stringValue": "Button"
                }
            },
            "createTime": "2019-04-26T02:46:17.349762Z",
            "updateTime": "2019-04-26T02:46:17.349762Z"
        },
        {
            "name": "projects/doorsign-3557c/databases/(default)/documents/elements/ADD4DB42-F8CB-41B2-9C4A-84FCA3EDBC22",
            "fields": {
                "backgroundImageUUID": {
                    "stringValue": "7EEAB76A-5D1D-4BEE-90C1-58380C75257E"
                },
                "elementType": {
                    "stringValue": "Page"
                },
                "hierarchyLevel": {
                    "integerValue": "2"
                },
                "parentID": {
                    "stringValue": "262A785A-730B-48C1-8344-D2B84FF13062"
                },
                "elementName": {
                    "stringValue": "News"
                },
                "childrenIDs": {
                    "arrayValue": {}
                }
            },
            "createTime": "2019-04-26T10:31:24.184151Z",
            "updateTime": "2019-04-26T10:31:35.025870Z"
        },
        {
            "name": "projects/doorsign-3557c/databases/(default)/documents/elements/CDA81FEB-91C0-4980-B85F-97D6E14F3859",
            "fields": {
                "elementType": {
                    "stringValue": "Page"
                },
                "hierarchyLevel": {
                    "integerValue": "2"
                },
                "parentID": {
                    "stringValue": "62B4C61B-F675-49CD-9363-DF320D57A705"
                },
                "elementName": {
                    "stringValue": "Courese"
                },
                "childrenIDs": {
                    "arrayValue": {}
                },
                "backgroundImageUUID": {
                    "stringValue": ""
                }
            },
            "createTime": "2019-04-26T02:46:17.619202Z",
            "updateTime": "2019-04-26T02:46:17.619202Z"
        },
        {
            "name": "projects/doorsign-3557c/databases/(default)/documents/elements/f7JY7Ri8VUbHHmzsaXd8",
            "fields": {
                "backgroundImageUUID": {
                    "stringValue": "F4B36581-B5AF-4D19-A501-D306F7336B6E"
                },
                "elementType": {
                    "stringValue": "Home"
                },
                "hierarchyLevel": {
                    "integerValue": "0"
                },
                "parentID": {
                    "stringValue": ""
                },
                "elementName": {
                    "stringValue": "Home"
                },
                "childrenIDs": {
                    "arrayValue": {
                        "values": [
                            {
                                "stringValue": "62B4C61B-F675-49CD-9363-DF320D57A705"
                            },
                            {
                                "stringValue": "262A785A-730B-48C1-8344-D2B84FF13062"
                            }
                        ]
                    }
                }
            },
            "createTime": "2019-04-26T02:45:24.842782Z",
            "updateTime": "2019-04-26T10:31:10.763717Z"
        }
    ]
}
####### TEXTBLOCKS JSON ######
textblocks_json = {
    "documents": [
        {
            "name": "projects/doorsign-3557c/databases/(default)/documents/textblocks/1mG8oqAvmp5Y4wSvXzHT",
            "fields": {
                "parentID": {
                    "stringValue": "1A462259-EF86-4094-AA53-50CB73548F41"
                },
                "alignment": {
                    "integerValue": "0"
                },
                "blockFontSize": {
                    "doubleValue": 38
                },
                "numberOfLines": {
                    "integerValue": "1"
                },
                "blockFontColor": {
                    "stringValue": "000000"
                },
                "blockText": {
                    "stringValue": ""
                },
                "orderPosition": {
                    "integerValue": "1"
                }
            },
            "createTime": "2019-04-26T02:46:49.878542Z",
            "updateTime": "2019-04-26T02:46:49.878542Z"
        },
        {
            "name": "projects/doorsign-3557c/databases/(default)/documents/textblocks/9EfKDXCWCuLcYC57bcXM",
            "fields": {
                "orderPosition": {
                    "integerValue": "0"
                },
                "parentID": {
                    "stringValue": "039E3E51-8E50-4F0F-B5F6-EE0F5C82DE9C"
                },
                "alignment": {
                    "integerValue": "0"
                },
                "blockFontSize": {
                    "doubleValue": 38
                },
                "numberOfLines": {
                    "integerValue": "1"
                },
                "blockFontColor": {
                    "stringValue": "000000"
                },
                "blockText": {
                    "stringValue": "Awesome Item #2"
                }
            },
            "createTime": "2019-04-26T02:46:58.042417Z",
            "updateTime": "2019-04-26T02:46:58.042417Z"
        },
        {
            "name": "projects/doorsign-3557c/databases/(default)/documents/textblocks/BIIgdiwoJm4trqjGYw0X",
            "fields": {
                "parentID": {
                    "stringValue": "CDA81FEB-91C0-4980-B85F-97D6E14F3859"
                },
                "alignment": {
                    "integerValue": "0"
                },
                "blockFontSize": {
                    "doubleValue": 38
                },
                "numberOfLines": {
                    "integerValue": "1"
                },
                "blockFontColor": {
                    "stringValue": "000000"
                },
                "blockText": {
                    "stringValue": "Great"
                },
                "orderPosition": {
                    "integerValue": "0"
                }
            },
            "createTime": "2019-04-26T02:46:31.332341Z",
            "updateTime": "2019-04-26T02:46:31.332341Z"
        },
        {
            "name": "projects/doorsign-3557c/databases/(default)/documents/textblocks/JUacTTmgkJ9uiJVH1r6g",
            "fields": {
                "numberOfLines": {
                    "integerValue": "1"
                },
                "blockFontColor": {
                    "stringValue": "000000"
                },
                "blockText": {
                    "stringValue": "Cool item #1"
                },
                "orderPosition": {
                    "integerValue": "0"
                },
                "parentID": {
                    "stringValue": "1A462259-EF86-4094-AA53-50CB73548F41"
                },
                "alignment": {
                    "integerValue": "0"
                },
                "blockFontSize": {
                    "doubleValue": 38
                }
            },
            "createTime": "2019-04-26T02:46:49.776967Z",
            "updateTime": "2019-04-26T02:46:49.776967Z"
        },
        {
            "name": "projects/doorsign-3557c/databases/(default)/documents/textblocks/REvcOXTM8OIjlFR6mhWP",
            "fields": {
                "alignment": {
                    "integerValue": "0"
                },
                "blockFontSize": {
                    "doubleValue": 28
                },
                "numberOfLines": {
                    "integerValue": "1"
                },
                "blockFontColor": {
                    "stringValue": "000000"
                },
                "blockText": {
                    "stringValue": "Fulton 460c"
                },
                "orderPosition": {
                    "integerValue": "1"
                },
                "parentID": {
                    "stringValue": "f7JY7Ri8VUbHHmzsaXd8"
                }
            },
            "createTime": "2019-04-26T02:45:59.072499Z",
            "updateTime": "2019-04-26T02:45:59.072499Z"
        },
        {
            "name": "projects/doorsign-3557c/databases/(default)/documents/textblocks/bp8XL1AQk0y0LHEllT27",
            "fields": {
                "orderPosition": {
                    "integerValue": "1"
                },
                "parentID": {
                    "stringValue": "CDA81FEB-91C0-4980-B85F-97D6E14F3859"
                },
                "alignment": {
                    "integerValue": "2"
                },
                "blockFontSize": {
                    "doubleValue": 38
                },
                "numberOfLines": {
                    "integerValue": "1"
                },
                "blockFontColor": {
                    "stringValue": "000000"
                },
                "blockText": {
                    "stringValue": "Awesome"
                }
            },
            "createTime": "2019-04-26T02:46:31.412937Z",
            "updateTime": "2019-04-26T02:46:31.412937Z"
        },
        {
            "name": "projects/doorsign-3557c/databases/(default)/documents/textblocks/cuv7eDqUQea9weWQyZD1",
            "fields": {
                "numberOfLines": {
                    "integerValue": "1"
                },
                "blockFontColor": {
                    "stringValue": "000000"
                },
                "blockText": {
                    "stringValue": ""
                },
                "orderPosition": {
                    "integerValue": "0"
                },
                "parentID": {
                    "stringValue": "ADD4DB42-F8CB-41B2-9C4A-84FCA3EDBC22"
                },
                "alignment": {
                    "integerValue": "0"
                },
                "blockFontSize": {
                    "doubleValue": 38
                }
            },
            "createTime": "2019-04-26T10:31:34.855852Z",
            "updateTime": "2019-04-26T10:31:34.855852Z"
        },
        {
            "name": "projects/doorsign-3557c/databases/(default)/documents/textblocks/miQiPt8KzOGC3tEK6JZx",
            "fields": {
                "parentID": {
                    "stringValue": "f7JY7Ri8VUbHHmzsaXd8"
                },
                "alignment": {
                    "integerValue": "0"
                },
                "blockFontSize": {
                    "doubleValue": 38
                },
                "numberOfLines": {
                    "integerValue": "1"
                },
                "blockFontColor": {
                    "stringValue": "923125"
                },
                "blockText": {
                    "stringValue": "Prof. Gallaugher"
                },
                "orderPosition": {
                    "integerValue": "0"
                }
            },
            "createTime": "2019-04-26T02:45:58.949440Z",
            "updateTime": "2019-04-26T10:31:09.968510Z"
        },
        {
            "name": "projects/doorsign-3557c/databases/(default)/documents/textblocks/pvxHTW9QqyJ804zkBfJV",
            "fields": {
                "alignment": {
                    "integerValue": "0"
                },
                "blockFontSize": {
                    "doubleValue": 28
                },
                "numberOfLines": {
                    "integerValue": "1"
                },
                "blockFontColor": {
                    "stringValue": "000000"
                },
                "blockText": {
                    "stringValue": "                     Wed. 1PM"
                },
                "orderPosition": {
                    "integerValue": "3"
                },
                "parentID": {
                    "stringValue": "f7JY7Ri8VUbHHmzsaXd8"
                }
            },
            "createTime": "2019-04-26T10:31:10.607493Z",
            "updateTime": "2019-04-26T10:31:10.607493Z"
        },
        {
            "name": "projects/doorsign-3557c/databases/(default)/documents/textblocks/xYMIBh0A7taSLyXLo1Xv",
            "fields": {
                "parentID": {
                    "stringValue": "f7JY7Ri8VUbHHmzsaXd8"
                },
                "alignment": {
                    "integerValue": "0"
                },
                "blockFontSize": {
                    "doubleValue": 28
                },
                "numberOfLines": {
                    "integerValue": "1"
                },
                "blockFontColor": {
                    "stringValue": "000000"
                },
                "blockText": {
                    "stringValue": "Office Hrs. Mon. 7PM"
                },
                "orderPosition": {
                    "integerValue": "2"
                }
            },
            "createTime": "2019-04-26T10:31:10.410256Z",
            "updateTime": "2019-04-26T10:31:10.410256Z"
        }
    ]
}
"""
# DONE TEMP

# the current working directory (where this file is)
cwd = ("/"+__file__).rsplit('/', 1)[0]
# Initialize the pyportal object and let us know what data to fetch and where
# to display it
# Query all elements
# print(">>> GET ELEMENTS FETCH call on PyPortal")
# DATA_SOURCE = "https://firestore.googleapis.com/v1beta1/projects/doorsign-3557c/databases/(default)/documents/elements/"   # pylint: disable=line-too-long
# DATA_LOCATION = [0, "documents"]

# pyportal = PyPortal(caption_font=cwd+"/fonts/AvenirNextCondensed-DemiBold-38.bdf", default_bg=0xFFFFFF,)
# pyportal = PyPortal(caption_font=cwd+"/fonts/Collegiate-24.bdf", default_bg=cwd+"/home_screen.bmp",)
# pyportal = PyPortal(url=DATA_SOURCE,
#                     default_bg=cwd+"/home_screen.bmp",)
# elements_json = pyportal.fetch()
# print(elements_json)

# data = pyportal.fetch()
# elements_json=json.loads(data)

DATA_SOURCE = "https://firestore.googleapis.com/v1beta1/projects/doorsign-3557c/databases/(default)/documents/elements/"   # pylint: disable=line-too-long
DATA_LOCATION = [0, "documents"]
pyportal = PyPortal(url=DATA_SOURCE, default_bg=0xFFFFFF,)
data = pyportal.fetch()
elements_json=json.loads(data)
elements_list=elements_json["documents"]

# Query all elements
# print(">>> GET TEXTBLOCKS FETCH call on PyPortal")
DATA_SOURCE = "https://firestore.googleapis.com/v1beta1/projects/doorsign-3557c/databases/(default)/documents/textblocks/"   # pylint: disable=line-too-long
textblocks_json = pyportal.fetch(DATA_SOURCE)
data = pyportal.fetch()
textblocks_json=json.loads(data)
textblocks_list=textblocks_json["documents"]

class IndexedTextBlock:
  def __init__(self, blockID, parentID, alignment, blockFontSize, numberOfLines, blockFontColor, blockText,
               orderPosition):
    self.blockID = blockID
    self.parentID = parentID
    self.alignment = alignment
    self.blockFontSize = blockFontSize
    self.numberOfLines = numberOfLines
    self.blockFontColor = blockFontColor
    self.blockText = blockText
    self.orderPosition = orderPosition

# cuts off the extra text before a cloud firestore documentID
def get_id(large_id):
  string_start = large_id.rfind("/") + 1
  return large_id[string_start:]

print("There are", len(elements_list), "elements in Cloud Firestore.")
print("There are", len(textblocks_list), "textblocks in Cloud Firestore.")

home_ID = -1
for i in range(len(elements_list)):
    if elements_list[i]["fields"]["elementType"]["stringValue"] == "Home":
        home_ID = i
        home_documentID = get_id(elements_list[i]["name"])

print("Home is at index: ", home_ID)
print("docID of Home is", home_documentID)
print("The children of home are", elements_list[home_ID]["fields"]["childrenIDs"]["arrayValue"])
print("The background image of home is", elements_list[home_ID]["fields"]["backgroundImageUUID"]["stringValue"])

textblocks_indexed_by_parent = []

for i in range(len(textblocks_list)):
    block_ID = get_id(textblocks_list[i]["name"])
    parentID = textblocks_list[i]["fields"]["parentID"]["stringValue"]
    blockText = textblocks_list[i]["fields"]["blockText"]["stringValue"]
    alignment = textblocks_list[i]["fields"]["alignment"]["integerValue"]
    blockFontSize = textblocks_list[i]["fields"]["blockFontSize"]["doubleValue"]
    numberOfLines = textblocks_list[i]["fields"]["numberOfLines"]["integerValue"]
    blockFontColor = textblocks_list[i]["fields"]["blockFontColor"]["stringValue"]
    orderPosition = textblocks_list[i]["fields"]["orderPosition"]["integerValue"]
    block = IndexedTextBlock(block_ID, parentID, alignment, blockFontSize, numberOfLines, blockFontColor, blockText,
                             orderPosition)
    textblocks_indexed_by_parent.append(block)

print("# of textblocks", len(textblocks_indexed_by_parent))

# REFERENCE_CONSTANTS
large_font = bitmap_font.load_font('/fonts/AvenirNextCondensed-Medium-38.bdf')
medium_font = bitmap_font.load_font('/fonts/AvenirNextCondensed-Medium-28.bdf')
small_font = bitmap_font.load_font('/fonts/AvenirNextCondensed-Medium-18.bdf')

font_choice=[large_font, medium_font, small_font]
block_font_sizes = [38, 28, 18]
block_font_heights = [60, 47, 33]

# Below is just to test the home screen, first. Then we'll update the ID based on the button touch
screen_parent_ID = home_documentID

screen_text_blocks = []
for block in textblocks_indexed_by_parent:
    if screen_parent_ID == block.parentID:
        screen_text_blocks.append(block)

# sort the screen's textblocks
screen_text_blocks.sort(key=lambda x: x.orderPosition)

text_start_y = 10
text_start_x = 30
block_x = text_start_x
block_size = 80 # I think this is just the max expected # of characters

def create_text_area(config):
    """Given a dictionary with a list of area specifications, create and return test area."""
    # I think size is the max # of characters on a line, so I put in 80. Try a huge # later when experimenting with wordwrap
    textarea = Label(config['font'], text=' '*config['size'])
    textarea.x = config['x']
    textarea.y = config['y']
    textarea.color = config['color']
    return textarea

# default_bg=cwd+"/home_screen.bmp",)
pyportal.set_background('upper_right_logo.bmp')

# start from top, then each time a textblock is set up, increase by the size of that textblock so next textblock starts below it.
block_y = text_start_y
for screen_text_block in screen_text_blocks:
    # block_y = block_y + block_font_heights[block_font_size_index]
    block_y = block_y + screen_text_block.blockFontSize
    block_font_size_index = block_font_sizes.index(screen_text_block.blockFontSize)
    block_font = font_choice[block_font_size_index]
    area_config = dict(x=block_x, y=block_y, size=block_size, color=int("0x"+screen_text_block.blockFontColor), font=block_font)
    text_area = create_text_area(area_config)
    text_area.text = screen_text_block.blockText
    pyportal.splash.append(text_area)

# find the children of the document_ID and build the buttons, if any
screen_parent_ID
print("The children of screen_parent_ID ", screen_parent_ID, "are", elements_list[home_ID]["fields"]["childrenIDs"]["arrayValue"])

print("docID of Home is", home_documentID)
print("The children of home are", elements_list[home_ID]["fields"]["childrenIDs"]["arrayValue"])
print("The background image of home is", elements_list[home_ID]["fields"]["backgroundImageUUID"]["stringValue"])

id_prefix = "projects/doorsign-3557c/databases/(default)/documents/elements/"

children_dicts = elements_list[home_ID]["fields"]["childrenIDs"]["arrayValue"]["values"]
print("children_IDs = ", children_dicts)
for child_dict in children_dicts:
    print("child_dict = ", child_dict)
    child_id = child_dict["stringValue"]
    # element_name = elements_list["child_ID"]["fields"]["elementName"]["arrayValue"]
    # find the dictionary where the name == the child_ID
    selected_element = next(item for item in elements_list if item["name"] == id_prefix+child_id)
    print("selected_element =", selected_element)
    button_name = selected_element["fields"]["elementName"]["stringValue"]
    print("button_name = ", button_name)

"""
def createButton(button_name):
        padding_around_text = 8.0

        let newButton = UIButton(frame: self.screenView.frame)
        newButton.setTitle(buttonName, for: .normal)
        newButton.titleLabel?.font = .boldSystemFont(ofSize: 13.0)
        newButton.sizeToFit()
        newButton.frame = CGRect(x: newButton.frame.origin.x, y: newButton.frame.origin.y, width: newButton.frame.width + (paddingAroundText*2), height: newButton.frame.height)
        newButton.backgroundColor=UIColor().colorWithHexString(hexString: "923125")
        newButton.addTarget(self, action: #selector(changeButtonTitle), for: .touchUpInside)
        return newButton

# block_size is 80, I think this is max # of characters
area_config = dict(x=30, y=200, size=block_size, color=int("0x"+screen_text_block.blockFontColor), font="Collegiate-24.bdf")
text_area = create_text_area(area_config)

"""
"""
button = Button(x=30, y=200,
                    width=60, height=20,
                    style=Button.SHADOWROUNDRECT,
                    fill_color=0x923125,
                    label="Courses", label_font="Collegiate-24.bdf", label_color=0x000000)
pyportal.splash.append(button.group)

# buttons.append(button)
"""

"""
    button = Button(x=spot['pos'][0], y=spot['pos'][1],
                    width=spot['size'][0], height=spot['size'][1],
                    style=Button.SHADOWROUNDRECT,
                    fill_color=spot['color'], outline_color=0x222222,
                    name=spot['label'])
    pyportal.splash.append(button.group)
    buttons.append(button)
"""

# Should be the end

"""
# def get_news():
#    global events_list
# below was indented when it was a function
print(">>> GET ELEMENTS FETCH call on PyPortal")
try:
    value = pyportal.fetch()
    elements_json=json.loads(value)
    elements_list=elements_json["documents"]
    print("There are", len(elements_list), "elements in Cloud Firestore.")
except (ValueError, RuntimeError) as e:
    print("Some error occured, retrying! -", e)
"""

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

def print_current_event():
        print("*** PRINTING CURRENT EVENT ", current_event, " ***")
        print(events_list[current_event]["fields"]["eventName"]["stringValue"])
        print(events_list[current_event]["fields"]["dateString"]["stringValue"])
        print(events_list[current_event]["fields"]["timeString"]["stringValue"])
        print(events_list[current_event]["fields"]["eventLocation"]["stringValue"])
        print(events_list[current_event]["fields"]["eventDescription"]["stringValue"])

        print(events_list[current_event]["fields"]["fontSize"]["integerValue"])
        print(events_list[current_event]["fields"]["startTime"]["timestampValue"])
        print("\n") # new line

        # line below is useful if you're using CloudFirestore w/o the app & want to insert
        # new line commands by typing \n. Firestore converts these to \\n, but the replace
        # below will remove the extra \ so that linefeeds show up.
        # event_details = events_list[current_event]["fields"]["details"]["stringValue"].replace("\\n","\n")

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
        # get_news()
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
        print("!!! TOUCH DETECTED: ", x, y)
        current_touch_point = (x, y)
        print("current_image = ", current_image)
        handle_start_press((x, y))
        # sleap to avoid pressing two buttons on accident
        time.sleep(.5)
        # clear p
        p_list = []
