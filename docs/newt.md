# Custom Newt colors

Some information to ease customizing [Newt](https://pagure.io/newt) colors,
used e.g. by `whiptail`. Text below has been adapted from [this
post](https://askubuntu.com/a/781062)).


## Color definitions

Default Newt colors can be overridden either by defining them directly in the
`NEWT_COLORS` environment variable, or by setting the `NEWT_COLORS_FILE`
environment variable to point to a file holding the definitions.

The structure of the definitions is:

    name=[fg],[bg][;|:|\n|\r|\t]name2=[fg],[bg]]...

where `name` can be (as extracted from 
[`newt.c`](https://pagure.io/newt/blob/master/f/newt.c)):

    root                  root fg, bg
    roottext              root text
    helpline              help line
    border                border fg, bg
    window                window fg, bg
    shadow                shadow fg, bg
    title                 title fg, bg
    button                button fg, bg
    actbutton             active button fg, bg
    compactbutton         compact button fg, bg
    checkbox              checkbox fg, bg
    actcheckbox           active checkbox fg, bg
    entry                 entry box fg, bg
    disentry              disabled entry fg, bg
    label                 label fg, bg
    listbox               listbox fg, bg
    actlistbox            active listbox fg, bg
    sellistbox            selected listbox
    actsellistbox         active & sel listbox
    textbox               textbox fg, bg
    acttextbox            active textbox fg, bg
    emptyscale            scale full
    fullscale             scale empty

while `bg` and `fg` can be (as extracted from 
[`newt.c`](https://pagure.io/newt/blob/master/f/newt.c)):

    color0  or black
    color1  or red
    color2  or green
    color3  or brown
    color4  or blue
    color5  or magenta
    color6  or cyan
    color7  or lightgray
    color8  or gray
    color9  or brightred
    color10 or brightgreen
    color11 or yellow
    color12 or brightblue
    color13 or brightmagenta
    color14 or brightcyan
    color15 or white


## Example

Example displaying a message box with red window background:

```sh
#!/usr/bin/env sh

NEWT_COLORS='
  window=,red
  border=white,red
  textbox=white,red
  button=black,white
' \
whiptail --msgbox "passwords don't match" 0 0
```
