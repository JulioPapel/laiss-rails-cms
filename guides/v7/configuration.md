---
prev: render_images
next: upgrading
---

# Configuration of LaissCMS

LaissCms configuration is done in the `config/laiss_cms/config.yml` file.

Use

~~~ bash
bin/rake laiss_cms:install
~~~

or

~~~ bash
bin/rails g laiss_cms:install
~~~

to generate it.

## The configuration file

Please [have a look into the source code](https://github.com/LaissCMS/laiss_cms/blob/master/config/laiss_cms/config.yml). The file is pretty well documentated and much more up to date then this guide.

## Environment related configurations

Beside using that one configuration file you also can seperate certain config settings for specific environments.

For example: You want to enforce SSL in production, while in your development environment you don't.

Its easy to achieve by setting up a second configuration file for development which contains nothing but the ssl enforcing setting.

Your apps default config:

~~~
your_app/config/laiss_cms/config.yml
~~~

Environment specific config:

~~~
your_app/config/laiss_cms/development.config.yml
~~~

::: tip NOTE
When running your application in development mode both config files get merged, while the environment specific config takes precedence over the default config.
:::
