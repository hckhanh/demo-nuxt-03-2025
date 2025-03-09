# use the official Bun image
# see all versions at https://hub.docker.com/r/oven/bun/tags
FROM oven/bun:1 AS base
WORKDIR /usr/src/app

# install dependencies into temp directory
# this will cache them and speed up future builds
FROM base AS install
RUN mkdir -p /temp/dev
COPY package.json bun.lock /temp/dev/
RUN cd /temp/dev && bun install --frozen-lockfile

# copy node_modules from temp directory
# copy all (non-ignored) project files into the image
# build the project
FROM base AS build
COPY --from=install /temp/dev/node_modules node_modules
COPY . .
RUN bun build

# copy production dependencies and source code into final image
FROM base AS release
COPY --from=build /usr/src/app/.output .

# run the app
USER bun
EXPOSE 3000/tcp
ENTRYPOINT [ "bun", ".output/server/index.mjs" ]
