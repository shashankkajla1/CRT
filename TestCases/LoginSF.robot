*** Settings ***
Resource      ../resources/Common.robot
Suite Setup                   Setup Browser
Suite Teardown                End suite


*** Test Cases ***
Login to SFDC 
    [Tags]    Login in SFDC Successfully
    Login


