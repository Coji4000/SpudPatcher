# SpudPatcher
!!!Currently Doesn't do anything other than create a file a couple pop ups!!!   ....if you pack the pbo it registers but does nothing.

SpudPatcher is an Arma 3 Server Admin Tool written with Powershell and WPF for aiding in the deployment of filePatches to end users.

Extracting the package creates a folder structure compatible with being loaded as a mod for Arma 3. The mod (currently does nothing) shows a pop-up when starting Arma 3 sharing helpful (hopefully customizable) information about SpudPatcher (and maybe your payload). 

Its primary function is actually the SpudPatcher.ps1 script which can configure, deploy, and remove filePatches based on a Default configuration. Configuration can be managed in a GUI or directly on disk. The config can be distributed to your squad.


Before continuing please understand a few things:

  -I am using this project as a learning experience. I do not often Dev anything. It's probably ugly and certainly could be done better.

  -I do not intend to become some long term developer or maintainer but I do have a grudge against leaving issues unhandled. Please help me get better by submitting an issue report!

  -!!This script can be destructive!! If you use this script you assume all responsibility for the results of its operation.

  -Any User running this script agrees to the above bullet; Admins, consider your users data like your own. Don't share a config that clobbers their stuff.

  -Using filePatches on a Public Server is a massively poor idea. Please consider directly editing the addon for private distribution instead.

  -You may use any piece of this for whatever you like. Don't be stinky.


SpudPatcher.ps1 can be run from anywhere on the local machine it looks for a Sprefs.xml file in its running location.

If that file does not exist it will run a few tasks to create it.

It checks your registry to see if it can find your Arma 3 installation. Prompts you for input if it can't find it.

It scans the Arma 3 directory for a list of folders. Scans payload directory for a list of folders.

Note: the script currently gets upset if it has to create a Sprefs.xml AND no payload folder exists.

If Sprefs.xml does exist, or once its completed creating it, it reads from the XML to set its parameters.

On subsequent runs, as long as it detects the specified xml file it will use the values included.

A window is displayed |after this isnt implemented|>  allowing adjustment of the Sprefs.xml via GUI as well as providing a few execution options.

The window displays each of the considered settings. $ArmaRoot $PatchRoot $BlackList $PayLoad

Each display includes an edit button

After each update the configuration file is updated and the new data displayed in the window

A ComboBox is Provided with various options like "Open Settings in Notepad", "Import Settings", "Refresh Settings", "Reset Settings to Default", "Deploy with Current Settings", "Remove Deploy List from Arma 3 Dir"

The Execute button executes the selected ComboBox Option

A Pane on the left shows the expected deployment. it subtracts blacklist from payload. This list is used for both Deploy and Remove option.

Import Settings allows you to pull a Sprefs.xml from wherever (thinking this will just pull those settings into your file but the code doesnt exist yet)

Reset reruns the first run tasks which include overwriting the Sprefs.xml with a default configuration

Deploy first DELETES any folders it finds in the Arma 3 directory that match the left pane. Then COPIES the folders to your Arma 3 Directory.

Remove just runs the DELETE portion from the Deploy step.

Destructive Options have a "last-chance" pop-up sharing the destructive steps it expects to take and allowing the user to abort.


...some time in between downloading it and using it you'll need to put filepatches into your payload folder
