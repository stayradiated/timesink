timesink
========

> Sychronise time between a client and a server

This is a fork of [NodeGuy/ServerDate](https://github.com/NodeGuy/ServerDate).

Differences:

- User supplies the server time however they want (websockets recommended).
- Server does not supply initial time stamp, client must initiate synchronise process.
- CoffeeScript. However I will probably convert it to JavaScript once I've got everything working.
