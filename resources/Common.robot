
*** Settings ***

Library                   QWeb
Library                   QForce
Library                   String
Library                   OperatingSystem


*** Variables ***
# IMPORTANT: Please read the readme.txt to understand needed variables and how to handle them!!
${BROWSER}                chrome
${username}             
${password}               
${french_un}
${french_pw}  
${login_url}              https://telus--staging.my.salesforce.com/            # Salesforce instance. NOTE: Should be overwritten in CRT variables
${home_url}               ${login_url}/lightning/page/home
${Production}             https://telus.my.salesforce.com
${home_url1}              ${Production}/lightning/page/home
${secret}                 
@{Close_Tabs}             Create List                    (//div[@role='tablist'])[1]//button[contains(@title,'Close')]
${ENVIRONMENT}            https://telus.my.salesforce.com

*** Keywords ***
Setup Browser
    # Setting search order is not really needed here, but given as an example 
    # if you need to use multiple libraries containing keywords with duplicate names
    Set Library Search Order                          QForce    QWeb
    Open Browser          about:blank                 ${BROWSER}
    SetConfig             LineBreak                   ${EMPTY}               #\ue000
    SetConfig             DefaultTimeout              20s                    #sometimes salesforce is slow
    Evaluate              random.seed()               random                 # initialize random generator
    LogScreenshot
End suite
    Close All Browsers
    LogScreenshot
Login
    [Documentation]       Login to Salesforce instance
    GoTo                  https://telus--staging.my.salesforce.com/
    TypeText              Username               ${username}             delay=1
    TypeText              Password               ${password}
    ClickText             Log In    
    Log To Console         "---------- User Able to Login Successfully --------------- "
    LogScreenshot
    # We'll check if variable ${secret} is given. If yes, fill the MFA dialog.
    # If not, MFA is not expected.
    # ${secret} is ${None} unless specifically given.
   # ${MFA_needed}=       Run Keyword And Return Status          Should Not Be Equal    ${None}       ${secret}
    #Run Keyword If       ${MFA_needed}               Fill MFA


Login in French
    [Documentation]       Login to Salesforce instance for French user
    GoTo                  ${login_url}
    TypeText              Username                    ${french_un}             delay=1
    TypeText              Password                    ${french_pw}
    ClickText             Log In
    Log To console        "---------- User Able to Login Successfully --------------- "
    LogScreenshot
    # We'll check if variable ${secret} is given. If yes, fill the MFA dialog.
    # If not, MFA is not expected.
    # ${secret} is ${None} unless specifically given.
   # ${MFA_needed}=       Run Keyword And Return Status          Should Not Be Equal    ${None}       ${secret}
    #Run Keyword If       ${MFA_needed}               Fill MFA







Login As
    [Documentation]       Login As different persona. User needs to be logged into Salesforce with Admin rights
    ...                   before calling this keyword to change persona.
    ...                   Example:
    ...                   LoginAs    Chatter Expert
    [Arguments]           ${persona}
    ClickText             Setup
    ClickText             Setup for current app
    SwitchWindow          NEW
    TypeText              Search Setup                ${persona}             delay=2
    ClickText             User                        anchor=${persona}      delay=5    # wait for list to populate, then click
    VerifyText            Freeze                      timeout=45                        # this is slow, needs longer timeout          
    ClickText             Login                       anchor=Freeze          delay=1      
    LogScreenshot

Fill MFA
    #${mfa_code}=         GetOTP    ${username}   ${secret}   ${login_url}    
    #TypeSecret           Verification Code       ${mfa_code}      
    ClickText            Verify 
    LogScreenshot

Home
    [Documentation]       Navigate to homepage, login if needed
    GoTo                  ${home_url}
    ${login_status} =     IsText                      To access this page, you have to log in to Salesforce.    2
    Run Keyword If        ${login_status}             Login
    ClickText             Home
    VerifyTitle           Home | Salesforce
    LogScreenshot

# Example of custom keyword with robot fw syntax
VerifyStage
    [Documentation]       Verifies that stage given in ${text} is at ${selected} state; either selected (true) or not selected (false)
    [Arguments]           ${text}                     ${selected}=true
    VerifyElement         //a[@title\="${text}" and @aria-checked\="${selected}"]
    LogScreenshot

DeleteAccounts
    [Documentation]       RunBlock to remove all data until it doesn't exist anymore
  #  ClickText             ${data}
    ClickText             Delete
    VerifyText            Are you sure you want to delete this account?
    ClickText             Delete                      2
    VerifyText            Undo
    VerifyNoText          Undo
    ClickText             Accounts                    partial_match=False
    LogScreenshot

DeleteLeads
    [Documentation]       RunBlock to remove all data until it doesn't exist anymore
  #  ClickText             ${data}
    ClickText             Delete
    VerifyText            Are you sure you want to delete this lead?
    ClickText             Delete                      2
    VerifyText            Undo
    VerifyNoText          Undo
    ClickText             Leads                    partial_match=False
    LogScreenshot

Complete Credit Assessment Required Status     
#[Documentation]       Add new credit check 
    [Arguments]       ${contact_name}  ${emp_type} 
      VerifyText       Credit Assessment Required    
      VerifyText       New Credit Check
      ClickText        New Credit Check
      ClickText        Check Credit                timeout= 35
      sleep            20
      VerifyText       Credit Assessment  
      VerifyText       (//div[contains(text(), 'Credit Assessment')]//following::lightning-formatted-text)[1]
      GetText          (//div[contains(text(), 'Credit Assessment')]//following::lightning-formatted-text)[1]
      VerifyText       Related
      ClickText        Related                     timeout= 35
      VerifyText       Add Credit Contact
      ClickText        Add Credit Contact          timeout=35
      ClickElement     (//input[contains(@id,'combobox-input')])[1]         timeout=20
      VerifyText        ${contact_name}                       timeout=20
      ClickText         ${contact_name}
      ClickElement     (//button[contains(@id,'combobox-button')])[2]
      ClickText         ${emp_type}             timeout=20
      ClickElement      //button[contains(@name, 'SaveEdit')]            timeout=30
      VerifyText        (//div[contains(text(), 'Credit Contact')]//following::lightning-formatted-text)[1]
      ClickElement      //button[contains(@title, 'Close CC-')]          timeout=30
      VerifyText        Submit
      ClickText         Submit
      Sleep             20
      ClickElement      //button[contains(@title, 'Close CAR-')]    timeout=20
      VerifyText        Approved                        
      Sleep             20
      Log To Console         "---------- Credit Assesment Completed --------------- "

      LogScreenshot

LegacyContract    
   [Documentation]    Complete the Legacy Flow for Contract
    ClickText        Existing Legacy Contract    timeout=180
    #ClickText       Other
    #ClickText       new-password
    VerifyText       Legacy Contract Type        timeout=20
    ClickElement     //input[contains(@class,'nds-input nds-listbox__option-text_entity')]
    ClickElement     //*[contains(text(),'Humboldt')]
    TypeText         (//input[contains(@class,'vlocity-input nds-input nds-input_mask')])[2]             12345
    ClickText        Save & Close                timeout=20
    VerifyText       Are you sure you want to save it for later?             timeout=20
    ClickText        //button//span[contains(text(),'OK')]                   timeout=20
    ClickText        Close Tab                   timeout=20
    ScrollText       12345                       timeout=50
    VerifyText       12345                       timeout=15
    ClickText        Next                        timeout=15
    Log To Console         "---------- Legacy Contract Completed --------------- "
    LogScreenshot

Legacy Contract For Quote Flow 
        [Documentation]   Legacy Contract For Quote Flow 
    Sleep   10    
    ClickText        Existing Legacy Contract    timeout=90                                                
    Dropdown         Legacy Contract Type                         Humboldt
    TypeText         Legacy Contract Number             12345
    ClickText        Save & Close      anchor=Cancel
    ClickText        Ok      anchor=Cancel     
    Sleep   04
    ClickText        Close Tab
    Sleep   04
    LogScreenshot

LegacyContract For Internal French   
       [Documentation]    Complete the Legacy Flow for Contract in French
    ClickText       Contrat légataire existant    timeout=180
    VerifyText       Sélectionner le type de contrat hérité et fournir le numéro de contrat
    ClickElement     //input[contains(@class,'nds-input nds-listbox__option-text_entity')]
    ClickElement     //*[contains(text(),'Humboldt')]
    TypeText         (//input[contains(@class,'vlocity-input nds-input nds-input_mask')])[2]             12345
    ClickText        Enregistrer et fermer                         timeout=30
    VerifyText       Êtes-vous sûr de vouloir enregistrer pour plus tard?             timeout=30
    ClickText        D'accord                              
    Sleep     03
    ClickText      Fermer l'onglet
    ScrollText       12345                       timeout=50
    VerifyText       12345                       
    ClickText        Suivant           anchor=Précédent    
    Sleep     06
    LogScreenshot




RCID 44
        [Documentation]   This will Select RCID 44 Account 
    [Arguments]      ${rcid44}      
    VerifyText       Search...                   anchor=Service Console      timeout=40
    GoTo             ${rcid44}                                               timeout=40
    Sleep    06
    #RefreshPage
    Sleep    06
    Log To Console         "---------- RCID Selected --------------- "
    LogScreenshot

RCID 22
    [Documentation]   This will Select RCID 22 Account
    [Arguments]      ${rcid22}    
    VerifyText       Search...                   anchor=Service Console      timeout=40
    GoTo             ${rcid22}                                               timeout=40
    Sleep    06
    #RefreshPage
    Sleep    08
    Log To Console         "---------- RCID Selected --------------- "
    LogScreenshot

RCID 33
       [Documentation]  This will Select RCID 33 Account
   [Arguments]      ${rcid33}      
   VerifyText       Search...                   anchor=Service Console      timeout=40
   GoTo            ${rcid33}                                                timeout=40
   Sleep    06
   #RefreshPage
   Sleep    06
   Log To Console         "---------- RCID Selected --------------- "
   LogScreenshot

RCID 44 French
        [Documentation]   This will Select RCID 44 Account 
    [Arguments]      ${rcid44}      
    VerifyText       Recherchez...                     anchor=Console de service     timeout=40
    GoTo             ${rcid44}                                               timeout=40
    Sleep    08
    RefreshPage
    Sleep    12
    LogScreenshot

RCID 22 French
        [Documentation]   This will Select RCID 22 Account
    [Arguments]      ${rcid22}    
    VerifyText         Recherchez...                     anchor=Console de service      timeout=40
    GoTo             ${rcid22}                                               timeout=40
    Sleep    08
    RefreshPage
    Sleep    12
    LogScreenshot

RCID 33 French
       [Documentation]  This will Select RCID 33 Account
   [Arguments]      ${rcid33}      
   VerifyText       Recherchez...                     anchor=Console de service      timeout=40
   GoTo            ${rcid33}                                                timeout=40
   Sleep    08
   RefreshPage
   Sleep    12
   LogScreenshot



Click On New Order
        [Documentation]  Click To the New Order Button
    Sleep     50 
    ScrollText       Orders                timeout=25   # ${Open_Order} : Excel import
    Sleep     06 
    VerifyText       Orders
    Sleep     20 
    ClickText        (//a[contains(text(),'Orders')])[2]//ancestor::article//button[text()\="New"]                         timeout=30
    Log To Console         "---------- Order Button Clicked --------------- "
    Sleep     15 

    ${Closewindow}                Get Element Count     //button[@title\="Close this window"]           
   
    IF    ${Closewindow} == 1
        Sleep            06
        ClickText    //button[@title\="Close this window"]
        Sleep            30 
        ClickText        (//a[contains(text(),'Orders')])[2]//ancestor::article//button[text()\="New"]                         timeout=30
    END     
  
    LogScreenshot

Click On Nouveau Order French
        [Documentation]  Click To the New Order Button
    ScrollText       Commandes                timeout=25   # ${Open_Order} : Excel import
    ClickText       (//a[contains(text(), 'Commandes')])[2]//ancestor::article//button[text()\="Nouveau"]
    LogScreenshot

Click On New Contract
        [Documentation]  Click On New Contract
        VerifyText       New Contract                timeout=360
        ClickText        New Contract                timeout=60
        Log To Console         "---------- Contract Button  Selected --------------- "
        Sleep   18
        LogScreenshot


Click On New Contract For French 
        [Documentation]  Click On New Contract
        VerifyText       Nouveau contrat                timeout=360
        ClickText        Nouveau contrat                timeout=60
        LogScreenshot

Click CheckBox Book Appointment
        [Documentation]  Click On New Contract
    Sleep        20    
    VerifyText       Same as order contact                              timeout=120
    Sleep     04
    ClickCheckbox    Same as order contact       on                     
    Sleep     22
    ScrollText       Refresh Calendars           timeout=45
    Sleep     24
    Log To Console         "---------- CheckBox on Book Appointment Selected --------------- "
    LogScreenshot


Click CheckBox Book Appointment in French
        [Documentation]  Click On CheckBox Book Appointment in French
    Sleep        20    
    VerifyText       Même contact que dans la commande?     timeout=80
    Sleep     04
    ClickCheckbox    Même contact que dans la commande?       on                            
    Sleep     22
    ScrollText       Actualiser les calendriers           timeout=45
    Sleep     24
    LogScreenshot 


Book An Appointment on October   # Depends on Order to Order 
       [Documentation]  Book Appointment on October
    TypeText          Search calendar      2023-10-22     timeout=360
    ClickElement     (//*[contains(@class,'nds-icon nds-icon-text-default nds-icon_small')])[2]    timeout=360
    ClickText         Book Now     timeout=360
    VerifyText        Your appointments have been booked     timeout=380
    ClickText         Next                        timeout=260
    LogScreenshot

Close Previous Tabs
         [Documentation]  Close Tabs 
    SetConfig            DefaultTimeout              25s 
    Sleep    20
    ${count_c}    GetElementCount  (//div[@role\="tablist"])[1]//button[contains(@title,'Close')]      timeout=35  
    Log      ${count_c}   
    FOR    ${check}    IN RANGE   ${count_c}

           ClickElement     (//div[@role\="tablist"])[1]//button[contains(@title,'Close')]
           Sleep  03
    END

    Log To Console    " ---- Total Tab Closed ------ "   
    LogScreenshot


Close Previous Tabs for French
         [Documentation]  Close Tabs for French user  
    SetConfig            DefaultTimeout              20s 
    Sleep    15
    ${count_French}    GetElementCount            //div[@class\="close slds-col--bump-left slds-p-left--none slds-context-bar__icon-action "]//button[@class\="slds-button slds-button_icon slds-button_icon-x-small slds-button_icon-container"]
       Log    ${count_French}

       FOR    ${checkFrench}    IN RANGE   ${count_French}

           ClickText            //div[@class\="close slds-col--bump-left slds-p-left--none slds-context-bar__icon-action "]//button[@class\="slds-button slds-button_icon slds-button_icon-x-small slds-button_icon-container"]
       END       
     LogScreenshot

Booking Appointments Slots 
        [Documentation]     Book Appointment Slot For Orders
         
    ${Appointment_count}     Set Variable       12
   
    FOR  ${appointment}   IN RANGE   ${Appointment_count}
         Sleep   20
        ${book_list}    GetElementCount      //div[contains(@class,'nds-align--absolute-center time-slot')]  timeout=40
       # ClickElement   //button//span[contains(text(),'Refresh Calendars')]   timeout=40
        Sleep   15

        IF    ${book_list} > 0 
                VerifyText          //div[contains(@class,'nds-align--absolute-center time-slot')]  timeout=40
               # ClickElement        //div[contains(@class,'nds-align--absolute-center time-slot')]  timeout=40
                Log To Console    "------- Appointment Booking Slots Are Present --------- "     
        BREAK
       
            ELSE
  
                Sleep   12
                VerifyElement     (//*[contains(@class,'nds-icon nds-icon-text-default nds-icon_small')])[2]  timeout=30
                ClickElement      (//*[contains(@class,'nds-icon nds-icon-text-default nds-icon_small')])[2]  
                Log To Console    "----- Next Button Clicked --------- "

        END

    END

    Sleep   14   
    VerifyElement   (//button//span[contains(text(),'Book Now')])[1]   timeout=40
    Sleep  08
    ClickElement    (//button//span[contains(text(),'Book Now')])[1]   timeout=40  
    VerifyText       Your appointments have been booked          timeout=240
    Sleep   20
    Log To Console     "----- Appointment Booked Successfully ---------------"
    ClickText        Next                        timeout=360
    LogScreenshot


Booking Appointments Slots For French
        [Documentation]     Book Appointment Slot For Orders
         
    ${Appointment_count}     Set Variable       12
   
    FOR  ${appointment}   IN RANGE   ${Appointment_count}
         Sleep   20
        ${book_list}    GetElementCount      //div[contains(@class,'nds-align--absolute-center time-slot')]  timeout=40
       # ClickElement   //button//span[contains(text(),'Refresh Calendars')]   timeout=40
        Sleep   15

        IF    ${book_list} > 0 
                VerifyText      //div[contains(@class,'nds-align--absolute-center time-slot')]  timeout=40
              #  ClickElement    //div[contains(@class,'nds-align--absolute-center time-slot')]  timeout=40
                Log To Console    "----- Appointment Booking Slots Are Present --------- "     
        BREAK
       
            ELSE
  
                Sleep   12
                VerifyElement     (//*[contains(@class,'nds-icon nds-icon-text-default nds-icon_small')])[2]  timeout=30
                ClickElement      (//*[contains(@class,'nds-icon nds-icon-text-default nds-icon_small')])[2]  
                Log To Console    "----- Next Button Clicked --------- "

        END

    END

    Sleep   14   
    VerifyElement   (//button//span[contains(text(),'Réserver maintenant')])[1]       timeout=40
    ClickElement    (//button//span[contains(text(),'Réserver maintenant')])[1]       timeout=40
    VerifyText              Vos rendez-vous ont été réservés                          timeout=250
    Log To Console     "----- Appointment Booked Successfully ---------------"
    ClickText               Suivant                anchor=Précédent                   timeout=360
    LogScreenshot

Order Summary
        [Documentation]     ORDER SUBMISSION 
    ${NoTSubmitted}       Set Variable                     //span[normalize-space(text())\="Not Submitted" and @class\="purpleTELUS"]     
    # //span[normalize-space(text())\="Not Submitted" and @class\="slds-badge ng-binding"]
    VerifyText           ${NoTSubmitted}      timeout=200
    ${SubmitButton}      Set Variable      Submit Order
    VerifyText             ${SubmitButton}        timeout=60     enabled=true

   ${Order_val}   Set Variable     3

   FOR   ${ord_val}     IN RANGE      ${Order_val} 
     
    ${No_Submitted}       GetElementCount       //span[normalize-space(text())\="Not Submitted" and @class\="purpleTELUS"]        timeout=30
    Sleep   10
     IF    ${No_Submitted} > 0
        Sleep   15
        VerifyText      Submit Order           
        ClickText       Submit Order             
        Log To Console  -- ORDER SUBMIT BUTTON CLICKED ---------
        Sleep   120
        RefreshPage
        Sleep   120
        RefreshPage
        Sleep   100
        RefreshPage
        Sleep   100
        RefreshPage
        Sleep   100
        ${Order_val}        Get Text      (//span[@class\="headingBackground bold"]//parent::span)[1]    timeout=30
        Log          ${Order_val}
        Sleep   15 
        Log To Console     " ----- ORDER Submitted   ------ "
        BREAK

    END 

   END
   
   Sleep  10
   ${validate_OrderStatus}      Get Element Count       //span[normalize-space(text())\="Submitted" and @class\="greenTELUS"]    timeout=40
   ${Vald_InProgressStatus}     Get Element Count       //span[@class\="greenTELUS" and text()\="In Progress"]                   timeout=40


       IF    ${validate_OrderStatus} > 0

            Sleep  06
            VerifyText         //span[normalize-space(text())\="Submitted" and @class\="greenTELUS"] 
            Log To Console    " ----- Order State ---> Submitted ------ "
        END

        IF   ${Vald_InProgressStatus} > 0

            Sleep  06
            VerifyText          //span[@class\="greenTELUS" and text()\="In Progress"]                  
            Log To Console    " ----- Order State ---> In Progress ------ "
        END



    LogScreenshot


Amend Update Order Internal 
      [Documentation]     Amend To Click Update Order Button after Clicking Submitted Order 
    Sleep       30

    ${Update_Amend}        Set Variable           3
 
    FOR    ${Amend}   IN RANGE     ${Update_Amend} 
        
      RefreshPage
      Sleep  25
      
      ${validate_progress}       GetElementCount                //button[@onclick\="promptDueDateBookingMsg('8018D000000mQG8QAM')"]       timeout=32  
      #//span[@class\="greenTELUS" and text()\="In Progress"]       timeout=35

        IF    ${validate_progress} == 0
             
             Sleep  30
             RefreshPage
             Sleep  30
             RefreshPage
             Sleep  35
             RefreshPage
             Sleep  35
       
        END
    
    
    END
   
    RefreshPage
    Sleep  45
    VerifyText             //button[@class\="telus-ordsummary-button" and text()\="Update Order"]     timeout=30       enabled=true
    ClickText             //button[@class\="telus-ordsummary-button" and text()\="Update Order"]
    Log To Console       " ---- Update Order Button Clicked -> Amend Process Starts <- --- "


Order Summary For Internal French
        [Documentation]     ORDER SUBMISSION 
    ${NoTSubmittedFrench}       Set Variable        //span[normalize-space(text())\="Non soumis" and @class\="slds-badge ng-binding"]
    VerifyText           ${NoTSubmittedFrench}      timeout=200
    ${SubmitButton}      Set Variable      Soumettre la commande                                  
    VerifyText             ${SubmitButton}        timeout=60 

   ${Order_val}   Set Variable     3

   FOR   ${ord_val}     IN RANGE      ${Order_val} 
     
    ${No_Submitted}       GetElementCount      //span[normalize-space(text())\="Non soumis" and @class\="slds-badge ng-binding"]   timeout=30
    Sleep   10
     IF    ${No_Submitted} > 0
        Sleep   15
        VerifyText      Soumettre la commande                                     
        ClickText       Soumettre la commande                                  
        Log To Console  -- ORDER SUBMIT BUTTON CLICKED ---------
        Sleep   140
        RefreshPage
        Sleep   120
        RefreshPage
        Sleep   120
        RefreshPage
        Sleep   120
        RefreshPage
        Sleep   120
        ${Order_val}        Get Text      (//span[@class\="headingBackground bold"]//parent::span)[1]    timeout=30
        Log          ${Order_val}
        Sleep   20
        VerifyText             //span[normalize-space(text())\="Soumis" and @class\="greenTELUS"]    timeout=40
        Log To Console     ----- ORDER Submitted  Successfully ------
        BREAK

    END 


   END
     LogScreenshot

Verify Update order button
    [Documentation]     Update Order button 
   VerifyText          //button[contains(@ng-disabled, 'disableUpdateOrder')]    timeout=200

    ${UpdateButton}      Set Variable      Update Order
    VerifyText             ${UpdateButton}        timeout=60 

   ${Order_val}   Set Variable     3

   FOR   ${ord_val}     IN RANGE      ${Order_val} 
     
    ${No_enableUpdate}       GetElementCount       //button[contains(@ng-disabled, 'disableUpdateOrder')]   timeout=30
    Sleep   10
     IF    ${No_enableUpdate} > 0
        Sleep   15
        Sleep   140
        RefreshPage
        Sleep   120
        RefreshPage
        Sleep   120
        RefreshPage
        Sleep   120
        RefreshPage
        Sleep   120
        RefreshPage
        Sleep   120
        RefreshPage
        Sleep   120
        RefreshPage
        Sleep   120
        RefreshPage
        Sleep   120
        RefreshPage
        Sleep   120
        RefreshPage
        Sleep   120
        ${Order_val}        Get Text      //button[contains(@ng-disabled, 'enableUpdateOrder')]    timeout=30
        Log          ${Order_val}
        Sleep   10
        VerifyText       //button[contains(@ng-disabled, 'enableUpdateOrder')]       timeout=40
        Log To Console     ----- Update order button enabled successfully ------
        BREAK

    END 


   END
    
    LogScreenshot


   
    
  
#Loading Test Data       
        #[Documentation]  Testing Data Flow  
        #Setup Browser  
        #${env}       Get Variable Value          ${ENVIRONMENT}
        #Log To Console      ${env}

      #  IF    ${env}     https://telus.my.salesforce.com
       #       Log To Console   Hello
        #      GoTo        https://telus.my.salesforce.com

        #END

Select user Contact For Internal 
        [Documentation]  Select The user Contact
    [Arguments]             ${contactName} 
    Sleep        06
    TypeText         Search by name, email or phone number                ${contactName}         timeout=120
    VerifyElement    selectContactRadio          tag=input                   timeout=15
    Sleep  06
    ClickElement     selectContactRadio          tag=input                   timeout=15
    ClickText        Next                            timeout=120
    Log To Console      " ------- Contact Detail Selected -------- "                                           
    LogScreenshot

Select user Contact For Quote Internal 
        [Documentation]  Select The user Contact for Quote 
    [Arguments]             ${contactName} 
    Sleep        06
    TypeText         Start typing the contact name                ${contactName}         timeout=120
    VerifyElement    selectContactRadio          tag=input                   timeout=15
    Sleep  06
    ClickElement     selectContactRadio          tag=input                   timeout=15
    ClickText        Next                                                    timeout=120
     LogScreenshot



Select user Contact For French Internal 
      [Documentation]  Select The user Contact
    [Arguments]             ${contactName} 
    TypeText         Rechercher un contact                ${contactName}         timeout=120
    VerifyElement    selectContactRadio          tag=input                   timeout=15
    Sleep  06
    ClickElement     selectContactRadio          tag=input                   timeout=15
    ClickText        Suivant                                                    timeout=120
      LogScreenshot
   
Select Top Offer Address for Internal
        [Documentation]  Select The Address for User Account
    [Arguments]      ${City}  ${Provience}   ${Country}  ${Address}    
    ClickText        Select address(es)          timeout=90
    TypeText         City                        ${City}                     timeout=30
    TypeText         Province                    ${Provience}                          timeout=30
    TypeText         Country                     ${Country}                         timeout=30
    VerifyText       ${Address}                                    timeout=50
    Sleep   08
   # ClickCheckbox    ${Address}         on                          timeout=50
    ClickCheckbox     //div[text()\=" ${Address}"]//ancestor::td/..//td//div//input[@type\="checkbox"]             on                          timeout=50
    #ClickText        //div[text()=' 506 34 AVENUE NE']//ancestor::td/..//td//div//input[@type='checkbox']
    ClickText        Select                      anchor=Close                timeout=60
    ClickText        Close                       anchor=Select               timeout=60
    ClickText        Next                        timeout=120
    Log To Console        " --------- Address Selected --------- "
    LogScreenshot

Select Top Offer Address for French Internal
        [Documentation]  Select The Address for User French Account
    [Arguments]      ${City}  ${Provience}   ${Country}  ${Address} 
    VerifyText       Sélection d'adresses         timeout=90  
    ClickText        Sélection d'adresses          timeout=90
    TypeText         Ville                        ${City}                     timeout=30
    TypeText         Province                    ${Provience}                          timeout=30
    TypeText         Pays                     ${Country}                         timeout=30
    VerifyText       ${Address}                                    timeout=50
    ClickCheckbox    ${Address}        on                          timeout=50
    ClickText        Sélectionner                anchor=Fermer                timeout=60
    ClickText        Fermer                       anchor= Sélectionner               timeout=60
    ClickText        Suivant                        timeout=120
    LogScreenshot



Select Top Offer For Internal 
         #[Documentation]          Add Offer to cart
    [Arguments]      ${Offer_name}
    TypeText         Search in:                   ${Offer_name}        timeout=340
    ClickText        Add to cart                 anchor= ${Offer_name}                           timeout=360
    Log To Console     " ---- Top Offer Added to Cart Clicked --------- "
    Sleep           12
    LogScreenshot 

Select Top Offer For Quote Internal 
         #[Documentation]          Add Offer to cart
    [Arguments]      ${Offer_name}
    TypeText         Search                       ${Offer_name}        timeout=340
    ClickText        Add to cart                 anchor= ${Offer_name}                           timeout=360
    Sleep           12   
    LogScreenshot  

Select Top Offer For Internal French
            [Documentation]          Add Offer to cart for Internal French
    [Arguments]      ${Offer_name}
    TypeText         Recherche dans:                   ${Offer_name}        timeout=340
    ClickText        Ajouter au panier                 anchor= ${Offer_name}                           timeout=360     
    LogScreenshot

Billing Shipping BAN Assignation for Internal 
    [Documentation]      Assing BAN for To Offer.
    [Arguments]      ${ban}
    VerifyText       Billing & Shipping          timeout=280
    VerifyText       Assign billing account      timeout=340
    ClickText        Assign billing account      timeout=15
    VerifyText       Customer account no. (CAN)                              timeout=60
    TypeText         //div/label[contains(text(),'Customer account no. (CAN)')]//ancestor::div[2]//input    ${ban}
    VerifyText       CORE AB
    ClickElement     //span[contains(text(),'${ban}')]/../..//ancestor::div[2]//label//span[@class\="nds-radio_faux"]
    ClickText       Save        timeout=30
    VerifyText      ${ban}   timeout=180
    ClickText       Next        timeout=30  
    Log To Console          "----------- Ban Assigned Successfully ----------"     
    LogScreenshot

Billing Shipping BAN Assignation for Internal French
    [Documentation]      Assing BAN for Internal French
    [Arguments]       ${BAN_Number}
    VerifyText       Détails de la facture          timeout=280
    VerifyText       Attribuer un compte de facturation      timeout=340
    ClickText        Attribuer un compte de facturation      timeout=15
    VerifyText      Numéro de compte client                              timeout=60
    TypeText         Numéro de compte client      ${BAN_Number} 
    ClickElement     //span[contains(text(),'${BAN_Number}')]/../..//ancestor::div[2]//label//span[@class\="nds-radio_faux"]
    ClickText       Enregistrer        timeout=30  
    Sleep       08
    VerifyText      ${BAN_Number}          timeout=35
    ClickText         Suivant        anchor=Précédent      timeout=50
    Sleep       08
    LogScreenshot
#  Get Order Details For Internal
#        [Documentation] 
#    [Arguments]                       ${orderVal}
#    ${Order_val}        Get Text      (//span[@class\="headingBackground bold"]//parent::span)[1]    timeout=30
#    Log          ${Order_val}     


eContract Registration
        [Documentation]              Complete the e-contract Flow for Contract 
    VerifyText                  eContract                   timeout=90
    ClickText                   Next                        timeout=80
    ClickText                   Next                        timeout=90
    ClickText                   Next                        timeout=90
    ClickText                   Next                        timeout=90
    ClickText                   Send Validation Request     timeout=150
    sleep                       20
    ClickText                   Next                        anchor=2                   timeout=90
    ClickElement                //button[@title\='Send']    timeout=90
    sleep                       20
    ClickElement                //button[@class\="slds-button slds-button_icon slds-button_icon-x-small slds-button_icon-container" and contains(@title,"Close 001")]    timeout=80
    sleep                       20
    VerifyText                    Contract          timeout=80
    ClickElement                //button[@title\="Close Contract"]    timeout=80
    sleep                       15
    RefreshPage
    VerifyText                  Contract Requests           timeout=80 
    #Customer Accepted
    ${my_Var}     Set Variable       10

    FOR   ${validate}     IN  RANGE   ${my_Var}
  
        Sleep                     15
        ScrollText                  Contract Requests          timeout=40
        Sleep    12
        ${var}                   Get Element Count      //span[text()\="Customer Accepted"]       timeout=30     


        IF  ${var} > 0
          
              Sleep   35
              RefreshPage
              Sleep   20
              ScrollText                  Contract Requests         timeout=80
              Sleep   20
              RefreshPage 
              Sleep   20
              ScrollText                  Contract Requests         timeout=80
              Sleep   35
              Log To Console  " ----- Validating Contract Registered Status ---------- "  
         
        END
        
    END

    ScrollText                  Contract Requests          timeout=40
    Sleep   06
    VerifyText            //span[text()\="Contract Registered"]           timeout=35
    Log To Console       " ------------- Contract Registered Successfully -------------- "
    Sleep   06
    ClickText          Next              anchor=Previous
    
    LogScreenshot



update e Contract    
    [Documentation]             Complete the Update e-contract Flow for Contract
    ClickElement                //lightning-icon[@title\="Update"]                     timeout=80
    VerifyText                  eContract                   timeout=20
    ClickText                   Next                        timeout=30
    ClickText                   Next                        timeout=30
    ClickText                   Next                        timeout=30
    ClickText                   Next                        timeout=30
    ClickText                   Send Validation Request     timeout=150
    sleep                       20
    ClickText                   (//button[contains(.,'Next')])[3]                      timeout=30
    ClickElement                //button[@title\='Send']    timeout=30
    sleep                       10
    ClickElement                //button[@class\="slds-button slds-button_icon slds-button_icon-x-small slds-button_icon-container" and contains(@title,"Close 001")]    timeout=80
    Sleep                       10
    ClickElement                //button[@title\="Close Update Contract"]              timeout=80
    sleep                       15
    RefreshPage
    VerifyText                  Contract Requests           timeout=60
    ClickText                   Next                        timeout=30
    LogScreenshot
Select Existing Credit check
    [Documentation]             select Existing credit check.
    [Arguments]                 ${creditcheck}
    ClickText                   Existing Credit Check       timeout=180
    TypeText                    Credit Assessment Required                             ${creditcheck}     timeout=60
    ClickText                   ${creditcheck}              anchor=2
    RefreshPage
    Sleep                       10
    VerifyText                  Approved
    LogScreenshot

Select Existing Credit check for Quote Flow
    [Documentation]             select Existing credit check.
    [Arguments]                 ${creditcheck}
    ClickText                   Existing Credit Check       timeout=180
    TypeText                    Credit Assessment Required                             ${creditcheck}     timeout=60
    ClickText                   ${creditcheck}              anchor=2
    RefreshPage
    Sleep                       10
    VerifyText                  Completed
    LogScreenshot