# devenv
Automate the build of a local docker Development image/container. Run the following locally:

Steps:

1. Create/download your AWS access Key ID and secret key  - and have them ready to paste into the console.
2. wget https://raw.githubusercontent.com/vikingmachine/devenv/master/bootstrap.sh && chmod +x bootstrap.sh && sh bootstrap.sh

get_session -d (download roles)
get_session -s <Authenticator PIN> (just enter any random password)
assume_role -l (list roles)
assume_role rolename
get_console_url rolename
