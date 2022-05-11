"""
Character Sheet
Manuel Marquez
SDEV 400 7380
5/10/22
"""

#every import needed for this project
import io
import datetime
import logging
import boto3
from botocore.exceptions import ClientError
from boto3.dynamodb.conditions import Key
from pprint import pprint

#establish session in my region, create resources for dynamodb and the table we will be using
sess=boto3.Session(region_name='us-east-1')
table = 'SDEV400Final'
dynamodb = boto3.resource("dynamodb")
ddb = sess.client('dynamodb')

#menu 1 lets a user enter character data to be stored in dynamodc and referenced later
def create_character():
    print('Welcome to character creation. Enter 0 to return to the menu ')
    character_name=input("Enter Character Name: ")
    if (character_name == '0'):
        menu
    player_name=input("Enter Player Name: ")
    if (player_name == '0'):
        menu
    cc=input("Enter Character Class (Subclasses and multiclass not yet available): ")
    cclass=cc.lower()
    if (cc == 0):
        menu    
    elif (cclass == "barbarian" or cclass == 'bard' or cclass =='cleric' or cclass =='druid' or 
        cclass =='fighter' or cclass =='monk'  or cclass == 'paladin' or cclass == 'ranger' or 
        cclass == 'rogue' or cclass == 'sorcerer' or cclass == 'warlock' or cclass == 'wizard') :
        try:
            level= int(input("Enter Character Level (1-20): "))
            if (level < 1 or level > 20):
                print("Character Level must be between 1-20")
            else:
                strength= int(input("Enter Strength Score(1-30): "))
                if (strength < 1 or strength > 30):
                    print("Character Statistics must be between 1-30")
                else:
                    dexterity= int(input("Enter Dexterity Score(1-30): "))
                    if (dexterity < 1 or dexterity > 30):
                        print("Character Statistics must be between 1-30")
                    else:
                        constitution=int(input("Enter Constitution Score (1-30): "))
                        if (constitution < 1 or constitution > 30):
                            print("Character Statistics must be between 1-30")
                        else:
                            intelligence=int(input("Enter Intelligence Score (1-30): "))
                            if (intelligence < 1 or intelligence > 30):
                                print("Character Statistics must be between 1-30")
                            else:
                                wisdom=int(input("Enter Wisdom Score (1-30): "))
                                if (wisdom < 1 or wisdom > 30):
                                    print("Character Statistics must be between 1-30")
                                else:
                                    charisma=int(input("Enter Charisma Score (1-30): "))
                                    if (charisma < 1 or charisma > 30):
                                        print("Character Statistics must be between 1-30")
                                    else:
                                        LVL=str(level)
                                        STR=str(strength)
                                        DEX=str(dexterity)
                                        CON=str(constitution)
                                        INT=str(intelligence)
                                        WIS=str(wisdom)
                                        CHA=str(charisma)
                                        item = {
                                            "Character Name": {
                                                "S": character_name
                                            },
                                            "Player Name": {
                                                "S": player_name
                                            },
                                            "CHA": {
                                                "N": CHA
                                            },
                                            "Class": {
                                                "S": cc
                                            },
                                            "CON": {
                                                "N": CON
                                            },
                                            "DEX": {
                                                "N": DEX
                                            },
                                            "INTEL": {
                                                "N": INT
                                            },
                                            "LVL": {
                                                "N": LVL
                                            },
                                            "STR": {
                                                "N": STR
                                            },
                                            "Token": {
                                                "S": f'sdev400finalbucket/{cclass}'
                                            },
                                            "WIS": {
                                                "N": WIS
                                            }
                                        }
                                        ddb.put_item(TableName=table, Item=item)
                                        print ('Character added')
                                        print (' ')
        #catch if a user tries to enter a non-numerical input
        except ValueError:
            print("Please enter a character level between 1-20 and character statistics between 3-30")
            print(" ")
    else:
        print("Invalid class selected, please enter one of the twelve classes in the 5e PHB")
        print(' ')


#menu 2 displays info for existing characters
def display_character():
    print ('Welcome to the Character Viewer')
    print('Here you can view a character that has already been created. Enter 0 to return to the menu')
    print(' ')
    char_name=input("Enter the Character's Name: ")
    if (char_name=='0'):
        menu
    play_name=input(" Enter the Character's Player's Name: ")
    if (play_name=='0'):
        menu
    table2=dynamodb.Table('SDEV400Final')
    try:
        resp = table2.query(KeyConditionExpression=(Key('Character Name').eq(char_name) & Key('Player Name').eq(play_name)))
            #json_course= json.loads(json.dumps(resp))
            #print(resp)
        for i in resp['Items']:
            print('Name: ' + i['Character Name'] + '                    Player: ' +i['Player Name'])
            print(' ')
            print('Class: ' +str(i['Class']) + '                    Level: ' +str(i['LVL'])) 
            print(' ')
            print('Str: ' +str(i['STR']))
            print('Dex: ' +str(i['DEX']))
            print('Con ' +str(i['CON']))
            print('Int ' +str(i['INTEL']))
            print('Wis: ' +str(i['WIS']))
            print('Cha: ' +str(i['CHA']))
            print('Token Link: ' +i['Token'])
            print(" ")
    #catch if the user enters a character and/or player that is not registered
    except ValueError:
        print("This Chacater and player compination does not exist, try another.")
    except:
        print("An error occured, please try again later")
        print(" ")


#menu 3 allows a user to pull a character and update them
def update_character():
    print ('Welcome to the Character Sheet Updater')
    print('Here you can pull an existing character and update their level and stats. Enter 0 to return to the menu')
    print(' ')
    char_name=input("Enter Character Name: ")
    play_name=input("Enter Player Name: ")
    table2=dynamodb.Table('SDEV400Final')
    done = False
    try :
        lvl=int(input('Enter new character level:  '))
        stats=input(f"Did {char_name}'s stats change? (y/n)")
        if (stats.lower() == 'y' or stats.lower() == 'yes'):
            STR=int(input("Enter new Strength score: "))
            DEX=int(input("Enter new Dexterity score: "))
            CON=int(input("Enter new Constitution score: "))
            IN=int(input("Enter new Intelligence score: "))
            WIS=int(input("Enter new Wisdom score: "))
            CHA=int(input("Enter new Charisma score: "))
            table2.update_item(
                Key={'Character Name': char_name, 'Player Name': play_name},
                UpdateExpression='SET LVL= :n, STR= :r, DEX= :d, CON= :o, INTEL= :i, WIS= :w, CHA= :h', 
                ExpressionAttributeValues= {':n': lvl, ':r':STR, ':d': DEX, ':o':CON, ':i':IN, ':w':WIS, ':h': CHA},
                ReturnValues="UPDATED_NEW")
            print(f"{char_name} successfully updated")
            print(' ')
        elif (stats.lower() == 'n' or stats.lower() == 'no'):
            table2.update_item(
                Key={'Character Name': char_name, 'Player Name': play_name},
                UpdateExpression='SET LVL= :n', 
                ExpressionAttributeValues= {':n': lvl},
                ReturnValues="UPDATED_NEW")
            print(f"{char_name} successfully updated")
            print(' ')
        elif (stats == '0'):
            menu
        else:
            print('Invalid Entry, please enter Y or N to update character or 0 to return to menu')
    except ValueError:
        print("Please enter a character level between 1-20 and character statistics between 3-30")
    except:
        print('Unable to update this character')

#menu 4 allows a user to delete a character
def delete_character():
    print('Welcome to the Character Deleter ')
    char_name=input("Enter Character Name: ")
    play_name=input("Enter Player Name: ")
    table2=dynamodb.Table('SDEV400Final')
    done = False
    while (done == False): 
        #Verify user wants to delete this character
        ask=input("Are you sure you want to delete " + char_name + " by " + play_name + " (Y/N): ")
        if (ask.upper() == "Y" or ask.upper() == "YES"):
            try:
                table2.delete_item(Key={'Character Name': char_name, "Player Name": play_name})
                logging.info(f'{char_name} was deleted')
                print(char_name + " was successfully deleted.")
                print(" ")
                done == True
            except ClientError as e:
                logging.error(e)
            except:
                print("Error finding character, try again")
            return done
        elif (ask.upper() == "N" or ask.upper() == "NO" or ask == '0'):
            done == True
            menu
            return done 
        else:
            print('Please enter either yes to confirm deletion or N/0 to exit it menu.')
            done == False


def add_token():
    print ('Welcome to the Token Uploader')
    object_name = input("Enter Token Name: ")
    file_path = input("Enter File Path: ")
    # Construct Body= parameter
    if isinstance(file_path, bytes):
        object_data = file_path
    elif isinstance(file_path, str):
        try:
            object_data = open(file_path, 'rb')
            # possible FileNotFoundError/IOError exception
        except UnboundLocalError as e:
            logging.error(e)
            print("Cannot find this file")
        except FileNotFoundError as e:
            logging.error(e)
            print("Cannot find this file")
    else:
        logging.error('Type of ' + str(type(file_path)) +
              ' for the argument \'file_path\' is not supported.')
    # Put the object
    s3 = boto3.client('s3')
    try:
        s3.put_object(Bucket='sdev400finalbucket', Key=object_name, Body=object_data)
    except ClientError as e:
    # AllAccessDisabled error == bucket not found
    # NoSuchKey or InvalidRequest error == (dest bucket/obj == src bucket/obj)
        logging.error(e)
        # Set up logging
        logging.basicConfig(level=logging.DEBUG,
                    format='%(levelname)s: %(asctime)s: %(message)s')
    except UnboundLocalError as e:
        logging.error(e)
        print("Cannot access data")
         # Put the object into the bucket
    success = object_name, file_path
    if success:
        logging.info(f'Added {object_name} to the Token Colection')
        print(f'Added {object_name} to the Tolen Colection')
        print(' ')
        
        
def view_token():
    print("Welcom to the Token Viewer")
    print("Here you can view tokens for each class and other images added by users.")
    tk=input("Enter Class or name image: ")
    s3 = boto3.resource('s3')
    try:
        s3.meta.client.download_file( 'sdev400finalbucket', tk, f'/home/ec2-user/environment/{tk}.jpg')
        print("Download Complete")
        print(" ")    
    except:
        print('Failed to find image.')
        

print("Welcome Adventurer to Your Online Character Creator.")
print("Choose from the menu below to create, view, alter, or delete existing character sheets.")
menu = {}
menu['1']='Create New Character'
menu['2']='View Existing Character'
menu['3']='Alter Existing Character'
menu['4']='Delete Existing Character'
menu['5']='Add Custom Token to Bucket'
menu['6']='View a Class Token or Custom Token'
menu['0']='Exit Program, Display date and time'


while True: 
    options=menu.keys()
    for entry in options: 
      print (entry, menu[entry])
    print(" ")
    selection=input("Please Select:")
    print(" ")
    if selection =='1': 
      create_character() 
      
    elif selection == '2': 
      display_character()

    elif selection == '3':
      update_character()
            
    elif selection == '4':
        delete_character()

    elif selection == '5': 
        add_token()
        
    elif selection == '6':
        view_token()
        
    elif selection == '0': 
        now = datetime.datetime.now()
        print("Safe Travels Adventurer!")
        print(now.strftime("%Y-%m-%d %H:%M:%S"))
        break
    else: 
      print("Unknown Option Selected!") 
      print(" ")

