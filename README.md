# penbuilder
Live Builds manager, focusing primarily on kali linux for building custom ISO's


## Kali 2016 Live Builds Manager
## INSTALL

```
mkdir ~/git && cd ~/git
git clone https://github.com/Cashiuus/penbuilder
cd penbuilder
```

## Conventions

1. Clone project. It will auto-retrieve the live-builds project for use.
2. All builds will occur under the git repo, within ${APP_BASE}/builds
3. All custom add-on files you wish to statically copy to the ISO's go in ${APP_BASE}/includes/
4. Completed Recipe ISO's (and an MD5 file) are copied to /var/www/html/isos/
5. The primary files you will use are the "recipe" scripts. Each of these will create a unique "recipe_name" folder within "/builds/" and store all work for that build there. This allows you to have many recipes, each stored in different build folders.



## Usage

1. Clone repo wherever you like, mine is at: /root/git/penbuilder/
2. Pick a recipe and run it. Since you don't yet have a "mybuilds.conf" file, it will create one.
3. Open the "config/mybuilds.conf" and edit settings to your liking.
4. Now, run the recipe and wait 20-50 minutes while your new ISO is built.
5. If you aren't copying it somewhere, it'll be at: {APP_BASE}/builds/<<recipe_name_folder>>/images/<your_new_iso>.iso



## Quick Background on Kali's Live-Build-Config workflow

1. Requires 'debootstrap' and 'live-build' to be installed
2. Removes all 'kali-config' files from the build config
3. Cleans the build config
4. Sets up the initial configuration
5. Executes the build process using its config located in ./auto/config


Note: An important note from this workflow, if you copy a file directly into the build configuration
that has the same filename as a default file in 'kali-config', it will be removed and overwritten
with the kali-config default file as part of this process. Therefore, you MUST place files like these
(e.g. preseed.cfg) into the 'kali-config' directory to avoid it being overwritten at the start of
the build process.


To Do:
1. Want to add HTTPS functionality to host ISO's and preseeds
