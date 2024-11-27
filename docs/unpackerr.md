
# Troubleshooting

## [Completed item still waiting no extractable files found at](https://github.com/Unpackerr/unpackerr/issues/169)

This trace in the logs (which is super noisy) is not to worry.

Unpackerr is just telling you something is stuck in your sonar queue. It's not an error, and it's not trying to extract it (because it has no compressed files). The fix is to figure out why it's stuck in the queue.


