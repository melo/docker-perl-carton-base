# Perl base image for Docker #

[![](https://images.microbadger.com/badges/image/melopt/perl-carton-base.svg)](https://microbadger.com/images/melopt/perl-carton-base "Get your own image badge on microbadger.com")

This base image uses the [latest perl official image](https://hub.docker.com/_/perl/)
as a starting point, and adds Carton to manage dependencies for
your Perl app. This image is updated automatically whenever
`perl:latest` changes.


> **Backwards incompatible change**: Dockerfiles don't have support
> for optional `COPY` instructions. What this means is that we cannot
> write a Dockerfile that works differently based on the presence or
> absence of a file or directory. To implement the hook system, this
> image now requires the project to have a non-empty `.docker-build-hooks`
> directory at the root of your projects.
>
> If you try to build your image and get an error like:
>
>     Step 1 : COPY .docker-build-hooks/* /app/
>     No source files were specified
>
> you need to add the `.docker-build-hooks` directory, with a file
> inside. See the "Quick Start" section for details.
>
> We hope to remove this requirement in the future if the Dockerfile
> specification gains support for this, and we apologize for this
> backwards incompatibility, we hope the flexibility the new hooks
> system provides compensates for this one-time fix.


# Quick Start #

Create a Dockerfile for your project with just this content:

    FROM melopt/perl-carton-base

You also need to create an empty folder for the hooks, even if you don't use them. On your project, do:

    mkdir .docker-build-hooks
    touch .docker-build-hooks/.keep

You should commit the `Dockerfile` and `.docker-build-hooks/.keep`
files to your repository.

*Note*: the `.keep` is needed because git doesn't version directories,
only files, so an empty directory would not be created when you
`git clone` the repository unless there is a file inside. Also
Dockerfile `COPY` will fail with empty directories.

The build process will make sure that:

* all dependencies listed in `cpanfile` and locked with `cpanfile.lockfile`
  (use `carton install` locally on your development laptop to create
  the second file) are installed under `/app/local`;
* your application is copied to the container under `/app`;
* the workdir is set to `/app` and and all commands run as `app`;
* all commands you execute with `docker run` are executed within `carton
  exec` to make sure your environment is sane, and PERL5LIB will include
  `/app/lib`, which allows you to just use your own application modules
  directly without futzing with `FindBin`.

More details below in the "Inside the box" section.


# Inside the box #

The image takes care of the usual boring stuff for all Perl projects
using Docker `ONBUILD` rules. These are executed when your own image
is built. We try to minimize the layer sizes, but at the same time
provide hooks that you can tweak to your needs.

The build process is a sequence of 5 steps or phases, each of those
has associated before and after optional hooks.

You can create an executable file inside the `.docker-build-hooks/`
directory at the root of you project with the correct format, and
this base image will call them in the proper moment. If any of the
hooks exists with status code different from 0, the build process
will terminate.

The format of the hook files is `<prefix>-<step_name>-<sequence_number>`.
The valid `<prefix>` values are `before` and `after`. The `<step_name>`
is defined below for each of the build steps. The `-<sequence_number>`
suffix is optional, and it is used to define the order in which
multiple hooks are executed. We `sort` the filenames alphanumerically
and execute them in order. Please note that `-10` will be executed
before `-2`. Use 0-padding like this: `-02`, `-04`, `-10`.


## Setup hooks ##

The fist build step is to initialize the hook system. We copy the contents of the `.docker-build-hooks/` directory to `/app`.

There is no `before-` hook, but you can define a `after-` hook using `init-hooks` as hook name.

You should use the `after-init-hooks` hook to install system packages that you might need to compile your dependencies afterwards.

For example, `apt-get install -y libmagic-dev` is required to install `File::LibMagic` Perl module.

## App user

Your application will be forced to run under the `app` user.

There are no hooks for this phase.


## Dependencies

The files `cpanfile` and `cpanfile.snapshot` are copied from the root of your project, and we execute `carton install --deployment` to install your Perl dependencies. We cleanup some of the build artifacts that both `carton` and `cpanm` tools create, to make sure your image is as small as possible.


## App copy

Afterwards, we copy all the files from your project into the `/app` directory.


## Final touches

The `CMD` you specify is forced to run under `carton exec` by using an `ENTRYPOINT` rule.

There are no hooks for this phase.


# How to use #

This is a Dockerfile for a simple Dancer app:

    FROM melopt/perl-carton-base

    ## Expose the default Dancer port
    EXPOSE 3000

    ## Start the app!
    CMD ["./bin/app.pl"]

Build it with the usual `docker build -t my_dancer_app`, and run it with
`docker run -it -p 3000:3000 my_dancer_app`. Update your frontend
nginx/varnish/apache server configuration to use the app port.

For a worker-style Perl app, the Dockerfile is even simpler:

    FROM melopt/perl-carton-base

    ## Start the app!
    CMD ["./bin/start_worker.pl"]

That's all it takes...


# Author

Pedro Melo, <melo@simplicidade.org>

