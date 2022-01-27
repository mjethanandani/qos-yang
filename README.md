# Introduction
Once the repository has been cloned, there are several ways to "build" this draft.

## Git Tag
The Makefile in the repository uses `git tag` to determine the version of the draft to build. To check all the tags associated with the repository, type:

`git tag`

and look for the latest version of the tag.

If the repository does not have all the latest tags uploaded, one can create a local tag by using the following command

`git tag draft-ietf-rtgwg-qos-model-<version>`

where the `version` field is the current published version of the draft. For example, if the current published version is -06, then the tag created should be:

`git tag draft-ietf-idr-bgp-model-06`

This tag will cause `draft-ietf-idr-bgp-model-07` to be built.

## Native Build

To build the draft on the machine where the repository exits, one has to
have all the tools neccesary. These include building other tools (from
source) used by this model, i.e. yanglint and yanger. Details on how
to build them can be found in the link to the tools. Be prepared that those tools in turn will require their own set of tools to build, e.g. cmake.

The tools needed to compile YANG include

- [yanger](https://github.com/mbj4668/yanger)
- [yanglint](https://github.com/CESNET/libyang)

Other than the tools do compile the YANG models, one will need

- python3 and python3-pip
- curl
- rsync
- idnits
- awk (or gawk installed as awk)
- gsed (or sed installed as gsed)

In addition pip should be used to install

- pyang
- xml2rfc
- xym

Once all the tools are installed the following commands will build the draft

`% cd draft`

`% make clean`

`% make`

## Build using Docker

In one does not want to be bothered with all the tools necessary to build
the draft, one can use Docker. Make sure Docker is installed and in the
root of the repository type

`% make`

or

`% make container`

### Output of Docker build

Since Docker mounts the host file system while building this draft, it will deposit the output of the build on the host file system.
