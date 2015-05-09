# Perl base image for Docker #

This base image uses the latest perl official image as a starting
points, and adds Carton to manage dependencies for your Perl app.

You can use pull it from `melopt/perl-carton-base`:

    docker pull melopt/perl-carton-base


# Inside the box #

The image takes care of the usual boring stuff.

We make sure the entire app runs with a non-root account `app`, and set
the Docker workdir to the home directory of the user, `/app`.

Also, to make the use of this image as a source easier, we also setup
Docker "on build" hooks to add the usual three steps that all Perl
applications would need:

* we copy the `cpanfile` file from the root of your project, and run
  `carton install`, to make sure your dependencies are installed;
* then copy all the files from your project into the `/app` directory;
* and we force whatever you put in `CMD` on your own app Dockerfile to
  run under `carton exec`, to make sure your app automagically finds the
  installed dependencies.

Have the appropriate amount of fun.


## How to use ##

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


## How to build your own copy ##

Just clone this repo, tweak it, and:

    docker build -t your_name/perl-carton-base .


## Author

Pedro Melo, <melo@simplicidade.org>

