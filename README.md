# devenv
Automate the build of a local docker Development image/container. Run the following locally:

Steps:

1. Create/download your AWS access Key ID and secret key  - and have them ready to paste into the console.
2. wget https://raw.githubusercontent.com/vikingmachine/devenv/master/bootstrap.sh && chmod +x bootstrap.sh && sh bootstrap.sh
3. get_session -d (download roles)
4. get_session -s <Authenticator PIN> (just enter any random password)
5. assume_role -l (list roles)
6. assume_role rolename
7. get_console_url rolename
