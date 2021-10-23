# Workshop Issues

## Papercuts

The following issues would help improve the overall product UX as well as the
lessons contained in this workshop:

1. **"Named API Keys"**

   - Improvements here would eliminate a lof of explanation around how to
     capture an API key for later use (e.g. to set it as an environment
     variable)

   Related:

   - https://trello.com/c/tUtPwOHq
   - https://github.com/sensu/sensu-go/issues/3599

1. **Support for pre-seeding pipeline resources?!**

   - For convenience only... it would be nice to pre-seed a fresh install with
     Sensu resources (e.g. assets, checks, filters, mutators, handlers, etc)

1. **Check interval should be optional for checks set to `publish: false`**

   - This basically just leaves the door open for new users to get confused;
     why is an interval needed when `check.publish: false`?

   Related:

   - https://github.com/sensu/sensu-go/issues/2623

