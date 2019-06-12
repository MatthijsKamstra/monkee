# TODO

example paths:

- `/foobar/monkee/www/python/pages/contact.html`
- `/foobar/monkee/www/python/pages/home.html`
- `/foobar/monkee/www/python/pages/about.html`
- `/foobar/monkee/www/python/posts/images.html`

simple out

- index : ``
- pages : `pages/*`
- posts : `posts/*`


export folder
`/foobar/monkee/www/python/`

pages folder
`/foobar/monkee/www/python/pages/*`

posts folder
`/foobar/monkee/www/python/posts/*
`

## Navigation

are pages

- home
- contact
- about

from the `index` folder the path would be

- home : `pages/home.html`
- contact : `pages/contact.html`
- about : `pages/about.html`

And from the `pages/*` folder the path would be

- home : `home.html`
- contact : `contact.html`
- about : `about.html`

And from the `posts/*` folder the path would be

- home : `../pages/home.html`
- contact : `../pages/contact.html`
- about : `../pages/about.html`
