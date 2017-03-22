# pass-pin

A [pass](https://www.passwordstore.org/) extension for generating
pins (Personal Identification Numbers).

## Usage

```
Usage:
    pass pin generate [--clip,-c] [--in-place,-i | --force,-f] pass-name [pin-length]
            Generate an *numeric* pin code of pass-length (or 8 if unspecified)
	    Optionally put it on the clipboard and clear board after 45 seconds.
	    Optionally replace only the first line of an existing file with a new pin.
```

## Example

Generate a pin:

```
$ pass otp generate pin-secret
[master c036259] Add generated password for pin-secret.
 1 file changed, 0 insertions(+), 0 deletions(-)
  create mode 100644 pin-secret.gpg
  The generated password for pin-secret is:
  06708105

$ pass show pin-secret
06708105
```

Generate a pin of different length

```
$ pass otp generate pin-secret 4
[master 6c2a58a] Add generated password for pin-secret.
 1 file changed, 0 insertions(+), 0 deletions(-)
  create mode 100644 pin-secret.gpg
  The generated password for pin-secret is:
  4270
```

Generate a pin and copy to clipboard
```
$ pass pin generate -c pin-secret
[master cd84da1] Add generated password for pin-secret.
 1 file changed, 0 insertions(+), 0 deletions(-)
  create mode 100644 pin-secret.gpg
  Copied pin-secret to clipboard. Will clear in 45 seconds.

```

All the other options supported by base `pass` is also supported, such as `--force`, `--inline`, and `--qrcode`.

## Installation

````
- Enable password-store extensions by setting ``PASSWORD_STORE_ENABLE_EXTENSIONS=true``
- Clone this repo and create a symlink (or just download the raw file) to `pin.bash` in `~/password-store/.extensions`
```

## Requirements

- `pass` 1.7.0 or later for extenstion support
- `qrencode` for generating QR code images

## License

```
Copyright (C) 2017 Hugh Davenport

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
```
