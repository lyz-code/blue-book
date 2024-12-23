[Unmanic](https://github.com/Unmanic/unmanic) is a simple tool for optimising your file library. You can use it to convert your files into a single, uniform format, manage file movements based on timestamps, or execute custom commands against a file based on its file size.


Simply configure Unmanic pointing it at your library and let it automatically manage that library for you.

Unmanic provides you with the following main functions:

- A scheduler built in to scan your whole library for files that do not conform to your configured file presets. Files found requiring processing are then queued.
- A file/directory monitor. When a file is modified, or a new file is added in your library, Unmanic is able to again test that against your configured file presets. Like the first function, if this file requires processing, it is added to a queue for processing.
- A handler to manage running multiple file manipulation tasks at a time.
- A Web UI to easily configure, manage and monitor the progress of your library optimisation.

You choose how you want your library to be.

Some examples of how you may use Unmanic:

- Transcode video or audio files into a uniform format using FFmpeg.
- Identify (and remove if desired) commercials in DVR recordings shortly after they have completed being recorded.
- Move files from one location to another after a configured period of time.
- Automatically execute FileBot rename files in your library as they are added.
- Compress files older than a specified age.
- Run any custom command against files matching a certain extension or above a configured file size.

# [Installation](https://docs.unmanic.app/docs/installation/docker)

# Configuration

## Prioritise the bigger files

Transcoding of big files yields better results, so it makes sense to prioritise the bigger files. A way to do it is to define different libraries pointing to the same path but using different priorities. For example I'm using:

- Huge movies:
  - path: `/libraries/movies`
  - exclude: 
    - files smaller than 10GB
  - priority: 1000
- Big movies:
  - path: `/libraries/movies`
  - exclude: 
    - files smaller than 5GB
    - files bigger than 10GB
  - priority: 100
- Small movies:
  - path: `/libraries/movies`
  - exclude: 
    - files bigger than 5GB
  - priority: 1

# Troubleshooting

## [Data panels don't have any data](https://github.com/Unmanic/unmanic/issues/318)

You need to add the plugin to the worker process

## [Data Panels give a DataTables warning](https://github.com/Unmanic/unmanic/issues/474)

If when you open the Data Panel you get this pop up message that says "DataTables warning: table id=history_completed_tasks_table - Invalid JSON response. For more information about this error, please see https://datatables.net/tn/1" uninstall and reinstall the plugin.

# References
- [Source](https://github.com/Unmanic/unmanic)
- [Docs](https://docs.unmanic.app/docs/)
- [API reference](https://unmanic.internal-services.duckdns.org/unmanic/swagger#/)
