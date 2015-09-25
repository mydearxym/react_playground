/**
 * React Static Boilerplate
 * https://github.com/koistya/react-static-boilerplate
 * Copyright (c) Konstantin Tarkus (@koistya) | MIT license
 */

export default async () => {
  await require('./clean')();
  await require('./copy')();
  const pages = await require('./pages')();
  await require('./bundle')({ pages });
  await require('./render')({ pages });
};
