# Big disclaimer!!!

I have absolutely no idea of what I'm doing. It's the first time I do this and I'm just recording what I'm learning. Use the contents of this page at your own risk.

I've made this document thinking mainly of using [AV1](#av1) as a video encoding algorithm, `ffmpeg` to do the transcoding and `jellyfin` to stream it, so the content is heavily 

# Initial guidance into the transcoding world

## Shall I transcode my library?

There are some discrepancies whether it makes sense to transcode your library. 

In my case I'm going to do it because disks are expensive (people compare with buying one disk, but to upgrade my NAS I need 5, so it would be around 1400$).

Here are other opinions: [1](https://www.reddit.com/r/AV1/comments/ymrs5v/id_like_to_encode_my_entire_library_to_av1/)

## [Do's and don'ts](https://wiki.x266.mov/blog/av1-for-dummies#dos--donts)

Due to a lot of misunderstandings about codecs and compression, there are a lot of common misconceptions that are held regarding video encoding. We'll start by outlining some bad practices:

- Don't encode the same video multiple times. This is a common mistake made by people new to video encoding. Every time you encode a video, you lose additional quality due to generation loss. This is because video codecs are lossy, and every time you encode a video, you lose more information. This is why it is important to keep the original video file if you frequently re-encode it.
- Don't blindly copy settings from others without understanding them. What works for one person's content and workflow may not work for yours. Even the default settings on many encoders are not optimal for most content.
- Don't assume that higher bitrate equates to better quality. Inefficient encoding can waste bits without improving visual quality, and efficient encoding can make lower bitrate video look drastically better than higher bitrate video using the same codec.
- Don't assume all encoders/presets/settings/implementations are created equal. Even given two encoding frameworks that use the same underlying encoder, you may achieve different results given encoder version mismatches or subtly different settings used under the hood.
- Don't use unnecessarily slow presets/speeds unless you have a specific need and ample time. W slower presets improve encoding efficiency most of the time, the quality gains reach a point of diminishing returns beyond a certain point. Use the slowest preset you can tolerate, not the slowest preset available.
- Don't blindly trust metric scores. It is unfortunate how trusted VMAF is considering how infrequently it correlates with visual fidelity in practice now that it has become so popular. Even the beloved SSIMULACRA2 is not a perfect one-to-one with the human eye.

Now, let's move on to some good practices:

- Experiment with different settings and compare the results.
- Consider your content type when choosing encoding settings. Film, animation, and sports all have different characteristics that benefit from distinct approaches.
- Keep your encoding software up-to-date; the encoding world moves quickly.
## [Types of transcoding](https://jellyfin.org/docs/general/server/transcoding/#types-of-transcoding)

There are four types of playback in jellyfin; three of which involve transcoding. The type being used will be listed in the dashboard when playing a file. They are ordered below from lowest to highest load on the server:

- Direct Play: Delivers the file without transcoding. There is no modification to the file and almost no additional load on the server.
- Remux: Changes the container but leaves both audio and video streams untouched.
- Direct Stream: Transcodes audio but leaves original video untouched.
- Transcode: Transcodes the video stream.

## Shall I use CPU or GPU to do the transcoding?

The choice between **CPU** or **GPU** for transcoding depends on your specific needs, including speed, quality, and hardware capabilities. Both have their pros and cons, and the best option varies by situation.

### CPU-Based Transcoding
#### Pros:
- **High Quality**: Software encoders like `libx264`, `libx265`, or `libsvtav1` produce better compression and visual quality at the same bitrate compared to GPU-based encoders.
- **Flexibility**: Supports a wider range of encoding features, tuning options, and codecs.
- **Optimized for Low Bitrates**: CPU encoders handle complex scenes more effectively, producing fewer artifacts at lower bitrates.
- **No Dedicated Hardware Required**: Works on any modern system with a CPU.

#### Cons:
- **Slower Speed**: CPU encoding is much slower, especially for high-resolution content (e.g., 4K or 8K).
- **High Resource Usage**: Consumes significant CPU resources, leaving less processing power for other tasks.

#### Best Use Cases:
- High-quality archival or master files.
- Transcoding workflows where quality is the top priority.
- Systems without modern GPUs or hardware encoders.

### GPU-Based Transcoding
#### Pros:
- **Fast Encoding**: Hardware-accelerated encoders like NVIDIA NVENC, AMD VCE, or Intel QuickSync can encode video much faster than CPUs.
- **Lower Resource Usage**: Frees up the CPU for other tasks during encoding.
- **Good for High-Resolution Video**: Handles 4K or even 8K video with ease.
- **Low Power Consumption**: GPUs are optimized for parallel processing, often consuming less power per frame encoded.

#### Cons:
- **Lower Compression Efficiency**: GPU-based encoders often produce larger files or lower quality compared to CPU-based encoders at the same bitrate.
- **Limited Features**: Fewer tuning options and sometimes less flexibility in codec support.
- **Artifact Risk**: May introduce visual artifacts, especially in complex scenes or at low bitrates.

#### Best Use Cases:
- Streaming or real-time encoding.
- High-volume batch transcoding where speed matters more than maximum quality.
- Systems with capable GPUs (e.g., NVIDIA GPUs with Turing or Ampere architecture).

### **Quality vs. Speed**
| **Factor**              | **CPU Encoding**              | **GPU Encoding**              |
|--------------------------|-------------------------------|--------------------------------|
| **Speed**                | Slower                       | Much faster                   |
| **Quality**              | Higher                       | Good but not the best         |
| **Bitrate Efficiency**   | Better                       | Less efficient                |
| **Compatibility**        | Broader                      | Limited by hardware support   |
| **Power Consumption**    | Higher                       | Lower                         |

---

### **Conclusion**
- For **quality-focused tasks** such as a whole library encoding: Use CPU-based encoding.
- For **speed-focused tasks** such as streaming with jellyfin: Use GPU-based encoding.

For more information read [1](https://www.reddit.com/r/PleX/comments/16w1hsz/cpu_vs_gpu_whats_the_smartest_choice/).
# [Video transcoding algorithms](https://jellyfin.org/docs/general/clients/codec-support/)
[This guide](https://developer.mozilla.org/en-US/docs/Web/Media/Formats/Video_codecs) introduces the video codecs you're most likely to encounter or consider using. I'm only going to analyse the ones that I might use.

When deciding which one to use check [jellyfin's video compatibility table](https://jellyfin.org/docs/general/clients/codec-support/#video-compatibility) or [test your browser's compatibility for any codec profile](https://cconcolato.github.io/media-mime-support/).

Without taking into account H264 8Bits AV1 is the one which has more compatibility support except for iOS (but who cares about them?).

## [AV1](https://wiki.x266.mov/blog/av1-for-dummies)

[AV1](https://wiki.x266.mov/docs/video/AV1) is a royalty-free video codec developed by the Alliance for Open Media. It is designed to replace VP9 and presently competes with H.266. AV1 is known for its high compression efficiency, which the marketing will have you believe reduces file sizes by up to 50% compared to H.264 and up to 30% compared to H.265 across the board. It is supported by several major browsers and is widely used across many streaming services and video platforms.

Before we dive in, it is important to understand why you may want to use AV1 instead of other codecs. The reality is that AV1 is not better than H.264/5 in every single scenario; video encoding is a complicated field, and the best codec for you will depend on your specific needs. AV1 excels in:

- Low to medium-high fidelity encoding
- Higher resolution encoding
- Encoding content with very little grain or noise
- Slow, non-realtime contexts (e.g. offline encoding)

The enumeration above still consists of broad strokes, but the point is to understand that AV1 is not a silver bullet. It will not automatically make your videos smaller while preserving your desired quality. To make things more difficult, the x264 & x265 encoders are very mature, while AV1 encoding efforts designed to meet the extremely complicated needs of the human eye are still in their infancy.

### AV1 current problems

The first problem I've seen is that Unmanic doesn't support AV1 very well, you need to write your own ffmpeg configuration (which is fine). Some issues that track this are [1](https://github.com/Unmanic/unmanic-plugins/issues/333), [2](https://github.com/Unmanic/unmanic/issues/181), [3](https://github.com/Unmanic/unmanic/issues/390), [4](https://github.com/Unmanic/unmanic/issues/471) or [5](https://github.com/Unmanic/unmanic-plugins/issues?q=is%3Aissue+is%3Aopen+av1)
#### [AV1 probably outdated problems](https://gist.github.com/dvaupel/716598fc9e7c2d436b54ae00f7a34b95#current-problems)

The original article is dated of early 2022 so it's probably outdated given the speed of this world.

- 10 bit playback performance is not reliable enough on average consumer hardware.
- AV1 tends to smooth video noticeably, even at high bitrates. This is especially appearant in scenes with rain, snow etc, where it is very hard to conserve details.
- Grainy movies are a weakpoint of AV1. Even with film grain synthesis enabled, it is very hard to achieve satisfying results. 

At the moment (early 2022, SVT-AV1 v0.9.0) it is a fairly promising, but not perfect, codec. It is great for most regular content, achieves great quality at small file sizes and appearantly keeps its promise of being considerably more efficient than HEVC.

The only area where it must still improve is grainy, detailed movie scenes. With such high-bitrate, bluray-quality source material it's hard to achieve visual transparency. If grain synthesis has improved enough and smooth decoding is possible in most devices, it can be generally recommended. For now, it is still in the late experimental phase.

### [AV1 encoders](https://wiki.x266.mov/blog/av1-for-dummies#encoders)
The world of AV1 encoding is diverse and complex, with several open-source encoders available, each bringing its own set of strengths, weaknesses, and unique features to the table.


- SVT-AV1
- rav1e
- aomenc (libaom)
- SVT-AV1-PSY

Understanding these encoders is crucial for making informed decisions about what best suits your specific encoding needs.

#### SVT-AV1

[SVT-AV1](https://wiki.x266.mov/docs/encoders/SVT-AV1) (Scalable Video Technology for AV1) is an AV1 encoder library and application developed by Intel, Netflix, and others. It has gained significant popularity in the encoding community due to its impressive balance of speed, quality, and scalability.

Links:
- Wiki page: [SVT-AV1](https://wiki.x266.mov/docs/encoders/SVT-AV1)
- Git repository: https://gitlab.com/AOMediaCodec/SVT-AV1
- Documentation: https://gitlab.com/AOMediaCodec/SVT-AV1/-/blob/master/Docs/README.md

1. **Performance & Scalability**
   - SVT-AV1 is renowned for its encoding speed, particularly at higher speed presets.
   - It leverages parallel processing, making it exceptionally efficient on multi-core systems. Fun fact: SVT-AV1's parallel processing is lossless, so it doesn't compromise quality for speed.

2. **Quality-to-Speed Ratio**
   - SVT-AV1 strikes an impressive balance between encoding speed and output quality.
   - At faster presets, it usually outperforms other encoders in quality per unit of encoding time.
   - While it may not achieve the absolute highest *quality per bit* possible, its quality is generally considered impressive for its speed.

3. **Flexibility**
   - SVT-AV1 offers a wide range of encoding options and presets, allowing fine-tuned control over the encoding process.
   - It provides 14 presets (0-13), with 0 being the slowest and highest quality, and 13 being the fastest but lowest quality.
   - Advanced options allow users to adjust parameters like hierarchical levels, intra-refresh type, and tuning modes.

4. **Continuous Development**
   - SVT-AV1 receives frequent updates and optimizations, with new releases often coming alongside big changes.
   - The open-source nature of the project encourages community contributions and rapid feature development.

SVT-AV1 is an excellent choice for a wide range of encoding scenarios. It's particularly well-suited for:
- High-volume encoding operations where speed is crucial
- Live or near-live encoding of high-resolution content
- Scenarios where a balance between quality and encoding speed is required
- Users with multi-core systems who want to leverage their hardware efficiently

Some downsides include:
- Higher memory usage compared to other encoders
- The developers assess quality via its performance on traditional legacy metrics, which harms its perceptual fidelity ceiling.

#### rav1e

[rav1e](https://wiki.x266.mov/docs/encoders/rav1e) is an AV1 encoder written in Rust & Assembly. Developed by the open-source community alongside Xiph, it brings a unique approach to AV1 encoding with its focus on safety and correctness.

Links:
- Wiki page: [rav1e](https://wiki.x266.mov/docs/encoders/rav1e)
- Git repository: https://github.com/xiph/rav1e
- Documentation: https://github.com/xiph/rav1e/tree/master/doc#readme

1. **Safety & Reliability**
   - Being written in Rust, rav1e emphasizes memory safety and thread safety.
   - This focus on safety translates to a more stable and reliable encoding process, with reduced risks of crashes or undefined behavior.

2. **High Fidelity**
   - At high fidelity targets - an area where AV1 usually lacks - rav1e is a strong contender compared to other encoders.
   - It excels in preserving fine details and textures, making it a good choice for high-fidelity encoding.

3. **Quality**
   - While not typically matching aomenc or SVT-AV1 in pure compression efficiency, rav1e can produce high-quality output videos.
   - It often achieves a good balance between quality and encoding time, especially at medium-speed settings.

4. **Perceptually Driven**
   - rav1e's development is driven by visual fidelity, without relying heavily on metrics.
   - This focus on perceptual quality leads to a stronger foundation for future potential improvements in visual quality, as well as making the encoder very easy to use as it does not require excessive tweaking.

rav1e is well-suited for:
- Projects where stability is paramount
- Users who prioritize a community-driven, open-source development approach
- Encoding tasks where a balance between quality and speed is needed, but the absolute fastest speeds are not required

Some limitations of rav1e include:
- Lagging development compared to other encoders
- Slower encoding speeds compared to SVT-AV1 at similar quality & size
- Fewer advanced options compared to other encoders

#### aomenc (libaom)

[aomenc](https://wiki.x266.mov/docs/encoders/aomenc), based on the libaom library, is the reference encoder for AV1. Developed by the Alliance for Open Media (AOM), it is the benchmark for AV1 encoding quality and compliance.

Links:
- Wiki page: [aomenc](https://wiki.x266.mov/docs/encoders/aomenc)
- Git repository: https://aomedia.googlesource.com/aom/

1. **Encoding Quality**
   - aomenc is widely regarded as the gold standard for AV1 encoding quality.
   - It often achieves high compression efficiency among AV1 encoders, especially at slower speed settings.
   - The encoder squeezes out nearly every last bit of efficiency from the AV1 codec, making it ideal for archival purposes or when quality per bit is critical.

2. **Encoding Speed**
   - aomenc is generally the slowest among major AV1 encoders.
   - It offers 13 CPU speed levels (0-12), but even at its fastest settings, it's typically slower than other encoders at their slower settings.
   - The slow speed is often considered a trade-off for its high compression efficiency.

3. **Extensive Options**
   - As the reference implementation, aomenc offers the most comprehensive encoding options.
   - It provides fine-grained control over nearly every aspect of the AV1 encoding process.
   - Advanced users can tweak many parameters to optimize for specific content types or encoding scenarios.

4. **Flexibility**
   - Being the reference encoder, aomenc produces highly standards-compliant AV1 bitstreams that take advantage of the full arsenal of AV1 features.
   - It supports 4:2:0 and 4:4:4 chroma subsampling, 8- to 12-bit color depth, and various other advanced features that more specialized encoders like SVT-AV1 do not support.

aomenc is ideal for:
- Scenarios where achieving the highest possible quality is the primary goal
- Archival encoding where compression efficiency is crucial
- Research and development in video compression
- Encoding projects where encoding time is not a significant constraint

Some drawbacks of aomenc include:
- Unresponsive development driven by legacy metrics, leading to slower adoption of new techniques and ignoring improvements communicated by people outside the Google development team
- Cripplingly difficult to use for beginners, with a culture of cargo-culting settings
- Slow encoding speeds compared to other AV1 encoders, which has less of an impact on the quality of the output than it used to compared to maturing encoders like SVT-AV1

#### SVT-AV1-PSY

[SVT-AV1-PSY](https://wiki.x266.mov/docs/encoders/svt-av1-psy) is a community fork of the SVT-AV1 encoder focused on psychovisual optimizations to enhance perceived visual quality. It aims at closing the distance between SVT-AV1's high speeds and the perceptual quality of aomenc's slow brute force approach.

Links:
- Wiki page: [SVT-AV1-PSY](https://wiki.x266.mov/docs/encoders/svt-av1-psy)
- Git repository: https://github.com/gianni-rosato/svt-av1-psy
- Documentation: https://github.com/gianni-rosato/svt-av1-psy/blob/master/Docs/PSY-Development.md

1. **Perceptual Optimizations**
   - SVT-AV1-PSY introduces various psychovisual enhancements to improve the perceived quality of encoded video.
   - These optimizations often result in output that looks better to the human eye, even if it might not always score as well in objective metrics.

2. **Additional Features**
    - Introduces new options like variance boost, which can help maintain detail in high-contrast scenes.
    - Offers alternative curve options for more nuanced control over the encoding process.
    - Extends the CRF (Constant Rate Factor) range to 70 (from 63 in mainline SVT-AV1), allowing for extremely low-bitrate encodes.
    - Introduces additional tuning options, including a new "SSIM with Subjective Quality Tuning" mode that can improve perceived quality.

3. **Visual Fidelity Focus**
   - Aims to produce more visually pleasing results, sometimes at the expense of metric performance.
   - Includes options like sharpness adjustment and adaptive film grain synthesis which can significantly impact the visual characteristics of the output.
   - Features modified defaults driven by perceptual quality considerations.

4. **Extended HDR Support**
   - Includes built-in support for Dolby Vision & HDR10+ encoding.
   - This makes it particularly useful for encoding HDR content without requiring additional post-processing steps or external tools.

5. **Performance**
   - Based on SVT-AV1, it retains the performance characteristics of its parent encoder.
   - Adds super slow presets (-2 and -3) for research purposes and extremely high-quality encoding. These additional presets can be useful for creating reference encodes or applications where encoding time is not a concern.

SVT-AV1-PSY is particularly well-suited for:
- Encoding scenarios where subjective visual quality is prioritized over pure metric performance
- HDR content encoding in Dolby Vision or HDR10+
- Users who want fine-grained control over psychovisual aspects of encoding
- Projects that require a balance between the speed of SVT-AV1 and enhanced visual quality
- Encoding challenging content with complex textures or high-contrast scenes

Some drawbacks are:
- Everything that applies to SVT-AV1, including the lack of support for 4:4:4 chroma subsampling and 12-bit color depth that are useful in specific scenarios
- There are no official ffmpeg builds with this fork, but there are community built binaries: 
  - https://github.com/Uranite/FFmpeg-Builds
  - https://github.com/Nj0be/HandBrake-SVT-AV1-PSY
  - https://www.reddit.com/r/AV1/comments/1fppk4d/ffmpeg_with_svtav1_psy_latest_for_windows_10_x64/

#### Conclusion

While SVT-AV1 is known for being fast, aomenc is renowned for its high-quality output, and rav1e is recognized for its safety and reliability, each encoder has strengths and weaknesses. The best encoder for you will depend on your specific needs and priorities.

I'll go with SVT-AV1 given that is the standard maintained by the community, and that SVT-AV1-PSY is not available by default in the tools that I am going to use (you'd need to compile it, and maintain it), and that I probably won't notice the difference.

## X265 (HVEC)

- Is not open source
## Conclusion

I'll use AV1 because:

- Is an open source, royalty free codec
- It's one of the most modern encoders
- It has a wide range of compatibility support 
- It has better compression rate than x265 and it seems to be faster? 
# Transcoding parameter comparison

## Check the original file transcoding information
To investigate the encoding details of an existing video file, you can use FFprobe (which comes with FFmpeg).

```bash
ffprobe -v quiet -print_format json -show_streams -show_format file_to_test.mp4
```

The metadata isn't always perfectly reliable, especially if the file has been modified or re-encoded multiple times.

## CRF comparison

Try to use CRF (Constant Rate Factor) for offline encoding, as opposed to CBR (onstant Bitrate) or VBR (Variable Bitrate). While the latter two are effective for precisely targeting a particular bitrate, CRF is more effective at targeting a specific quality level efficiently. So avoid the `-b:v 0` `ffmpeg` flag.

Check these articles [1](https://ottverse.com/analysis-of-svt-av1-presets-and-crf-values/), [2](https://academysoftwarefoundation.github.io/EncodingGuidelines/EncodeAv1.html#crf-comparison-for-libsvtav1) and [3](https://gitlab.com/AOMediaCodec/SVT-AV1/-/blob/master/Docs/Ffmpeg.md) for an interesting comparison between `presets` and `crf` when encoding in AV1.

A good starting point for 1080p video is `crf=30`.
### Can you compare values of CRF between video algorithms?

No, CRF (Constant Rate Factor) values are not directly comparable between different encoding algorithms like AV1 and H.265. Each codec has its own unique compression characteristics, so a CRF of 32 in AV1 will look different from a CRF of 32 in H.265, and similarly, a CRF of 21 will have different visual qualities.

Here's a more detailed explanation:

1. Codec-Specific Compression:
   - Each codec (AV1, H.265, H.264, etc.) has its own compression algorithm and efficiency
   - AV1 is generally more efficient at compression compared to H.265
   - This means a higher CRF value in AV1 might produce similar or better quality compared to a lower CRF in H.265

2. Rough Equivalence Guidelines:
   While not exact, here are some rough comparative CRF ranges:
   - H.264: CRF 18-28
   - H.265: CRF 20-28
   - AV1: CRF 25-35

### Script to see the quality difference by changing the CRF

It's recommended to test encodes at different CRF values and compare for your specific content:

- File size versus visual quality 
- Review objective quality metrics

You can use the next script for that:

```bash
#!/bin/bash

# Input video file
input_video="$1"
initial_time="00:15:00"
probe_length="00:01:00"

# Extract original segment
ffmpeg -i "$input_video" -ss $initial_time -t "$probe_length" -c copy original_segment.mkv

# Array of CRF values to test
crfs=(28 30 32 34 36)

# Create a size comparison log
echo "CRF Comparison:" >size_comparison.log
echo "Original Segment Size:" >>size_comparison.log
original_size=$(du -sh original_segment.mkv)
echo "$original_size" >>size_comparison.log
echo "-------------------" >>size_comparison.log

# Create a quality metrics log
echo "CRF Quality Metrics Comparison:" >quality_metrics.log
echo "-------------------" >>quality_metrics.log

for crf in "${crfs[@]}"; do
	# Encode test segments
	ffmpeg -i "$input_video" \
		-ss "$initial_time" -t "$probe_length" \
		-c:v libsvtav1 \
		-preset 5 \
		-crf $crf \
		-g 240 \
		-pix_fmt yuv420p10le \
		preview_crf_${crf}.mkv

	# Create a side by side comparison to see the differences
	ffmpeg -i original_segment.mkv -i preview_crf_${crf}.mkv \
		-filter_complex \
		"[0:v][1:v]hstack=inputs=2[v]" \
		-map "[v]" \
		-c:v libx264 \
		side_by_side_comparison_original_vs_crf_${crf}.mkv

	# Log file size
	size=$(du -h preview_crf_${crf}.mkv | cut -f1)
	echo "CRF $crf: $size" >>size_comparison.log

	# Measure PSNR and SSIM
	ffmpeg -i original_segment.mkv -i preview_crf_${crf}.mkv \
		-filter_complex "[0:v][1:v]psnr=stats_file=psnr_${crf}.log;[0:v][1:v]ssim=stats_file=ssim_${crf}.log" -f null -
	psnr_value=$(grep "psnr_avg:" psnr_${crf}.log | awk -F'psnr_avg:' '{sum += $2; count++} END {if (count > 0) print sum / count; else print "N/A"}')
	ssim_value=$(grep "All:" ssim_${crf}.log | awk -F'All:' '{sum += $2; count++} END {if (count > 0) print sum / count; else print "N/A"}')

	# Log the results
	echo "CRF $crf:" >>quality_metrics.log
	echo "  PSNR: ${psnr_value:-N/A}" >>quality_metrics.log
	echo "  SSIM: ${ssim_value:-N/A}" >>quality_metrics.log
	echo "-------------------" >>quality_metrics.log
done

# Create a side by side comparison of the most compressed versus the least
ffmpeg -i preview_crf_${crfs[1]}.mkv -i preview_crf_${crfs[-1]}.mkv \
	-filter_complex \
	"[0:v][1:v]hstack=inputs=2[v]" \
	-map "[v]" \
	-c:v libx264 \
	side_by_side_comparison_crf_${crfs[1]}_vs_crf_${crfs[-1]}.mkv

# Measure PSNR and SSIM between the different crfs
ffmpeg -i preview_crf_${crfs[1]}.mkv -i preview_crf_${crfs[-1]}.mkv \
	-filter_complex "[0:v][1:v]psnr=stats_file=psnr_crfs_max_difference.log;[0:v][1:v]ssim=stats_file=ssim_crfs_max_difference.log" -f null -
psnr_value=$(grep "psnr_avg:" psnr_crfs_max_difference.log | awk -F'psnr_avg:' '{sum += $2; count++} END {if (count > 0) print sum / count; else print "N/A"}')
ssim_value=$(grep "All:" ssim_crfs_max_difference.log | awk -F'All:' '{sum += $2; count++} END {if (count > 0) print sum / count; else print "N/A"}')

# Log the results
echo "CRF ${crfs[1]} vs CRF ${crfs[-1]}:" >>quality_metrics.log
echo "  PSNR: ${psnr_value:-N/A}" >>quality_metrics.log
echo "  SSIM: ${ssim_value:-N/A}" >>quality_metrics.log
echo "-------------------" >>quality_metrics.log

# Display results
cat size_comparison.log
cat quality_metrics.log
```

It will:
- Create a `original_segment.mp4` segment so you can compare the output
- Create a series of `preview_crf_XX.mkv` files with a 1 minute preview of the content
- Create a list of `side_by_side_comparison` files to visually see the difference between the CRF factors
- Create a quality metrics report `quality_metrics.log` by analysing the SSIM and PSNR tests (explained below)
- A `size_comparison.log` file to see the differences in size.

#### Results

##### CRF vs file size

I've run this script against three files with the next results:
- Big non animation file: "H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10", 1920x1080, profile high, bit rate 23439837

  ```
  Original Segment Size:
  152M    original_segment.mp4
  -------------------
  CRF 28: 12M
  CRF 30: 9.9M
  CRF 32: 8.5M
  CRF 34: 7.4M
  CRF 36: 6.6M
  ```

- Big animation file: "H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10", 1920x1038, profile high

  ```
  Original Segment Size:
  136M    original_segment.mp4
  -------------------
  CRF 28: 12M
  CRF 30: 9.5M
  CRF 32: 8.0M
  CRF 34: 6.8M
  CRF 36: 6.0M
  ```

- small non animation file:

  ```
  Original Segment Size:
  5.9M    original_segment.mp4
  -------------------
  CRF 28: 5.4M
  CRF 30: 4.9M
  CRF 32: 4.5M
  CRF 34: 4.1M
  CRF 36: 3.7M

  ```
##### Compare the SSIM and PSNR results

PSNR (Peak Signal-to-Noise Ratio) measures the quality of the reconstruction of the image. It calculates the ratio between the maximum possible signal (pixel values) and the noise (the error between the original and reconstructed image). Higher PSNR means better quality. 

The range typically goes between 30-50dB, where 40 dB is considered excellent and 35dB is good, while less than 30 dB indicates noticeable quality loss

[SSIM (Structural Similarity Index Measure)](https://en.wikipedia.org/wiki/Structural_similarity_index_measure) evaluates the perceptual similarity between two images by considering luminance, contrast, and structure. It ranges from -1 to 1, where 1 means identical images. Typically, > 0.95 is considered very good

- Big non animation file: 

  ```
  CRF Quality Metrics Comparison:
  -------------------
  CRF 28:
    PSNR: 37.6604
    SSIM: 0.963676
  -------------------
  CRF 30:
    PSNR: 37.6572
    SSIM: 0.96365
  -------------------
  CRF 32:
    PSNR: 37.6444
    SSIM: 0.963535
  -------------------
  CRF 34:
    PSNR: 37.6306
    SSIM: 0.963408
  -------------------
  CRF 36:
    PSNR: 37.6153
    SSIM: 0.963276
  -------------------
  CRF 30 vs CRF 36:
    PSNR: 51.0188
    SSIM: 0.996617
  -------------------
  ```

- Big animation file: 

  ```
  CRF Quality Metrics Comparison:
  -------------------
  CRF 28:
    PSNR: 34.6944
    SSIM: 0.904112
  -------------------
  CRF 30:
    PSNR: 34.6695
    SSIM: 0.903986
  -------------------
  CRF 32:
    PSNR: 34.6388
    SSIM: 0.903787
  -------------------
  CRF 34:
    PSNR: 34.612
    SSIM: 0.903616
  -------------------
  CRF 36:
    PSNR: 34.5822
    SSIM: 0.903423
  -------------------
  CRF 30 vs CRF 36:
    PSNR: 49.5002
    SSIM: 0.99501
  -------------------
  ```

- small non animation file:

  ```
  CRF Quality Metrics Comparison:
  -------------------
  CRF 28:
    PSNR: 35.347
    SSIM: 0.957198
  -------------------
  CRF 30:
    PSNR: 35.3302
    SSIM: 0.957124
  -------------------
  CRF 32:
    PSNR: 35.3035
    SSIM: 0.956993
  -------------------
  CRF 34:
    PSNR: 35.2767
    SSIM: 0.956848
  -------------------
  CRF 36:
    PSNR: 35.2455
    SSIM: 0.95666
  -------------------
  CRF 30 vs CRF 36:
    PSNR: 49.4795
    SSIM: 0.995958
  -------------------
  ```

### CRF conclusion 

In all cases the PSNR and SSIM values are very good, there is not much variability between the different CRF and it looks it changes more based on the type of video, working worse for animation.

The side by side comparisons in the three cases returned similar results that my untrained eye was not able to catch big issues. I have to say that my screens are not very good and I'm not very picky.

The size reduction is in fact astonishing being greater as the size of the original file increases. So it will make sense to transcode first the biggest ones.

As I don't see many changes, and the recommended setting is CRF 30 I'll stick with it.

## Preset comparison

This parameter governs the efficiency/encode-time trade-off. Lower presets will result in an output with better quality for a given file size, but will take longer to encode. Higher presets can result in a very fast encode, but will make some compromises on visual quality for a given crf value. Since SVT-AV1 0.9.0, supported presets range from 0 to 13, with higher numbers providing a higher encoding speed.

Note that preset 13 is only meant for debugging and running fast convex-hull encoding. In versions prior to 0.9.0, valid presets are 0 to 8. 

After checking above articles [1](https://ottverse.com/analysis-of-svt-av1-presets-and-crf-values/), [2](https://academysoftwarefoundation.github.io/EncodingGuidelines/EncodeAv1.html#crf-comparison-for-libsvtav1), [3](https://gitlab.com/AOMediaCodec/SVT-AV1/-/blob/master/Docs/Ffmpeg.md) and [4](https://wiki.x266.mov/blog/svt-av1-third-deep-dive) I feel that a preset of `4` is the sweet spot, going to `3` for a little better quality or `5` for a little worse. AOMediaCodec people agrees: "Presets between 4 and 6 offer what many people consider a reasonable trade-off between quality and encoding time". 

And [wiki x266 also agrees](https://wiki.x266.mov/blog/svt-av1-third-deep-dive): It appears as if once again preset 2 through preset 4 remain the most balanced presets all-around in an efficient encoding scenario, with preset 3 not offering much improvements over preset 4 in average scores but nicely improving on consistency instead, and preset 2 offering a nice efficiency and consistency uplift on top. 

Clear quality gains can be observed as we decrease presets, until preset 2, however the effectiveness of dropping presets is noticeably less and less important as quality is increased.

## [keyframe interval](https://trac.ffmpeg.org/wiki/Encode/AV1#Keyframeplacement)

`-g` flag in ffmpeg. This parameter governs how many frames will pass before the encoder will add a key frame. Key frames include all information about a single image. Other (delta) frames store only differences between one frame and another. Key frames are necessary for seeking and for error-resilience (in VOD applications). More frequent key frames will make the video quicker to seek and more robust, but it will also increase the file size. For VOD, a setting a key frame once per second or so is a common choice. In other contexts, less frequent key frames (such as 5 or 10 seconds) are preferred. Anything up to 10 seconds is considered reasonable for most content, so for 30 frames per second content one would use -g 300, for 60 fps content -g 600, etc. 

By default, SVT-AV1's keyframe interval is 2-3 seconds, which is quite short for most use cases. Consider changing this up to 5 seconds (or higher) with the -g option ; `-g 120` for 24 fps content, `-g 150` for 30 fps, etc. 

Using a higher GOP via the `-g` ffmpeg parameter results in a more efficient encode in terms of quality per bitrate, at the cost of seeking performance. A common rule-of-thumb among hobbyists is to use ten times the framerate of the video, but not more than `300`.

The 3 files I'm analysing are using 24fps so I'll use a `-g 240`

## Film grain

Consider using grain synthesis for grainy content, as AV1 can struggle with preserving film grain efficiently, especially when encoding high-quality content like old films or videos with a lot of grain detail. This is due to the fact that AV1's compression algorithms are optimized for clean, detailed content, and they tend to remove or smooth out film grain to achieve better compression ratios.
  
Grain synthesis is the process of adding synthetic grain to a video to simulate or preserve the original grain structure.

### [SVT-AV1 guidelines](https://gitlab.com/AOMediaCodec/SVT-AV1/-/blob/master/Docs/Ffmpeg.md)
The film-grain parameter enables this behavior. Setting it to a higher level does so more aggressively. Very high levels of denoising can result in the loss of some high-frequency detail, however.


[The film-grain synthesis](https://trac.ffmpeg.org/wiki/Encode/AV1#Filmgrainsynthesis) feature is invoked with `-svtav1-params film-grain=X`, where `X` is an integer from `1` to `50`. Higher numbers correspond to higher levels of denoising for the grain synthesis process and thus a higher amount of grain.

The grain denoising process can remove detail as well, especially at the high values that are required to preserve the look of very grainy films. This can be mitigated with the `film-grain-denoise=0` option, passed via svtav1-params. While by default the denoised frames are passed on to be encoded as the final pictures (`film-grain-denoise=1`), turning this off will lead to the original frames to be used instead. Passing film-grain-denoise=0 may result in higher fidelity by disabling source denoising. In that case, the correct film-grain level is important because a more conservative smoothing process is used--too high a film-grain level can lead to noise stacking.

AOMediaCodec people suggests that a value of 8 is a reasonable starting point for live-action video with a normal amount of grain. Higher values in the range of 10-15 enable more aggressive use of this technique for video with lots of natural grain. For 2D animation, lower values in the range of 4-6 are often appropriate. If the original video does not have natural grain, this parameter can be omitted.

There are two types of video that are called "animation": hand-drawn 2D and 3D animated. Both types tend to be easy to encode (meaning the resulting file will be small), but for different reasons. 2D animation often has large areas that do not move, so the difference between one frame and another is often small. In addition, it tends to have low levels of grain. Experience has shown that relatively high crf values with low levels of film-grain produce 2D animation results that are visually good.

3D animation has much more detail and movement, but it sometimes has no grain whatsoever, or only small amounts that were purposely added to the image. If the original animated video has no grain, encoding without film-grain will increase encoding speed and avoid the possible loss of fine detail that can sometimes result from the denoising step of the synthetic grain process.

For more information on the synthetic grain check [this appendix](https://gitlab.com/AOMediaCodec/SVT-AV1/-/blob/master/Docs/Appendix-Film-Grain-Synthesis.md)

### Film grain analysis

Using a similar script as the one for the crf we can see the differences in film grain:

```bash
#!/bin/bash

# Input video file
input_video="$1"
initial_time="00:15:00"
probe_length="00:01:00"

# Extract original segment
ffmpeg -i "$input_video" -ss $initial_time -t "$probe_length" -c copy original_segment.mkv

# Array of grain values to test
grains=(0 4 8 12)

# Create a size comparison log
echo "Grain Comparison:" >size_comparison.log
echo "Original Segment Size:" >>size_comparison.log
original_size=$(du -sh original_segment.mkv)
echo "$original_size" >>size_comparison.log
echo "-------------------" >>size_comparison.log

# Create a quality metrics log
echo "Grain Quality Metrics Comparison:" >quality_metrics.log
echo "-------------------" >>quality_metrics.log

for grain in "${grains[@]}"; do
	# Encode test segments
	ffmpeg -i "$input_video" \
		-ss "$initial_time" -t "$probe_length" \
		-c:v libsvtav1 \
		-preset 4 \
		-crf 30 \
		-g 240 \
		-pix_fmt yuv420p10le \
		-c:a libopus \
		-b:a 192k \
		-svtav1-params tune=0:film-grain=${grain} \
		preview_grain_${grain}.mkv

	# Create a side by side comparison to see the differences
	ffmpeg -i original_segment.mkv -i preview_grain_${grain}.mkv \
		-filter_complex \
		"[0:v][1:v]hstack=inputs=2[v]" \
		-map "[v]" \
		-c:v libx264 \
		side_by_side_comparison_original_vs_grain_${grain}.mkv

	# Log file size
	size=$(du -h preview_grain_${grain}.mkv | cut -f1)
	echo "grain $grain: $size" >>size_comparison.log

	# Measure PSNR and SSIM
	ffmpeg -i original_segment.mkv -i preview_grain_${grain}.mkv \
		-filter_complex "[0:v][1:v]psnr=stats_file=psnr_${grain}.log;[0:v][1:v]ssim=stats_file=ssim_${grain}.log" -f null -
	psnr_value=$(grep "psnr_avg:" psnr_${grain}.log | awk -F'psnr_avg:' '{sum += $2; count++} END {if (count > 0) print sum / count; else print "N/A"}')
	ssim_value=$(grep "All:" ssim_${grain}.log | awk -F'All:' '{sum += $2; count++} END {if (count > 0) print sum / count; else print "N/A"}')

	# Log the results
	echo "grain $grain:" >>quality_metrics.log
	echo "  PSNR: ${psnr_value:-N/A}" >>quality_metrics.log
	echo "  SSIM: ${ssim_value:-N/A}" >>quality_metrics.log
	echo "-------------------" >>quality_metrics.log
done

# Create a side by side comparison of the most compressed versus the least
ffmpeg -i preview_grain_${grains[1]}.mkv -i preview_grain_${grains[-1]}.mkv \
	-filter_complex \
	"[0:v][1:v]hstack=inputs=2[v]" \
	-map "[v]" \
	-c:v libx264 \
	side_by_side_comparison_grain_${grains[1]}_vs_grain_${grains[-1]}.mkv

# Measure PSNR and SSIM between the different grains
ffmpeg -i preview_grain_${grains[1]}.mkv -i preview_grain_${grains[-1]}.mkv \
	-filter_complex "[0:v][1:v]psnr=stats_file=psnr_grains_max_difference.log;[0:v][1:v]ssim=stats_file=ssim_grains_max_difference.log" -f null -
psnr_value=$(grep "psnr_avg:" psnr_grains_max_difference.log | awk -F'psnr_avg:' '{sum += $2; count++} END {if (count > 0) print sum / count; else print "N/A"}')
ssim_value=$(grep "All:" ssim_grains_max_difference.log | awk -F'All:' '{sum += $2; count++} END {if (count > 0) print sum / count; else print "N/A"}')

# Log the results
echo "grain ${grains[1]} vs grain ${grains[-1]}:" >>quality_metrics.log
echo "  PSNR: ${psnr_value:-N/A}" >>quality_metrics.log
echo "  SSIM: ${ssim_value:-N/A}" >>quality_metrics.log
echo "-------------------" >>quality_metrics.log

# Display results
cat size_comparison.log
cat quality_metrics.log

```

#### Old Anime movie

The quality results give:

```
Grain Quality Metrics Comparison:
-------------------
grain 0:
  PSNR: 34.6503
  SSIM: 0.902562
-------------------
grain 4:
  PSNR: 34.586
  SSIM: 0.900882
-------------------
grain 8:
  PSNR: 34.446
  SSIM: 0.897354
-------------------
grain 12:
  PSNR: 34.2961
  SSIM: 0.893525
-------------------
grain 4 vs grain 12:
  PSNR: 52.005
  SSIM: 0.994478
-------------------
```

The quality metrics show that with more grain the output file is less similar than the original, but the side by side comparison shows that even a grain of 12 is less noise than the original. It can be because the movie is old.

`grain == 0`
![](anime-old-grain-0.jpg) 

`grain == 8`
![](anime-old-grain-8.jpg) 

And I'd say that grain 8 looks better than 0.

#### Old movie with low quality

```
Grain Quality Metrics Comparison:
-------------------
grain 0:
  PSNR: 35.3513
  SSIM: 0.957167
-------------------
grain 4:
  PSNR: 35.3161
  SSIM: 0.956516
-------------------
grain 8:
  PSNR: 35.275
  SSIM: 0.955738
-------------------
grain 12:
  PSNR: 35.2481
  SSIM: 0.955299
-------------------
grain 4 vs grain 12:
  PSNR: 59.7537
  SSIM: 0.999178
-------------------
```

With the increase of grain also the metrics differ from the original, but less drastically than the anime movie. I'm not able to see any notable difference in the side by side comparison at any grain level. It can be either because the low quality makes it undetectable or that the scenes of the sample don't represent well the noise contrast.

#### Conclusion

Given that I don't notice any notable change by tunning the parameter, I'll go with the suggested `film-grain=8`.

## `pix_fmt` parameter

The `pix_fmt` parameter can be used to force encoding to 10 or 8 bit color depth. By default SVT-AV1 will encode 10-bit sources to 10-bit outputs and 8-bit to 8-bit.

AV1 includes 10-bit support in its Main profile. Thus content can be encoded in 10-bit without having to worry about incompatible hardware decoders.

To utilize 10-bit in the Main profile, use `-pix_fmt yuv420p10le`. For 10-bit with 4:4:4 chroma subsampling (requires the High profile), use `-pix_fmt yuv444p10le`. 12-bit is also supported, but requires the Professional profile. See ffmpeg -help encoder=libaom-av1 for the supported pixel formats. 

The [dummies guide](https://wiki.x266.mov/blog/av1-for-dummies) suggests to always use 10-bit color, even with an 8-bit source. AV1's internal workings are much more suited to 10-bit color, and you are almost always guaranteed quality improvements with zero compatibility penalty as 10-bit color is part of AV1's baseline profile.

The AOMediaCodec people say that encoding with 10-bit depth results in more accurate colors and fewer artifacts with minimal increase in file size, though the resulting file may be somewhat more computationally intensive to decode for a given bitrate.

If higher decoding performance is required, using 10-bit YCbCr encoding will increase efficiency, so a lower average bitrate can be used, which in turn improves decoding performance. In addition, passing the parameter `fast-decode=1` can help (this parameter does not have an effect for all presets, so check the parameter description for your preset). Last, for a given bitrate, 8-bit yuv420p can sometimes be faster to encode, albeit at the cost of some fidelity.

I'll then use `-pix_fmt yuv420p10le`

## [Tune parameter](https://gitlab.com/AOMediaCodec/SVT-AV1/-/blob/master/Docs/CommonQuestions.md#options-that-give-the-best-encoding-bang-for-buck)

This parameter changes some encoder settings to produce a result that is optimized for subjective quality (tune=0) or PSNR (tune=1). Tuning for subjective quality can result in a sharper image and higher psycho-visual fidelity.

This is invoked with `-svtav1-params tune=0`. The default value is 1.

The use of subjective mode (--tune=0) often results in an image with greater sharpness and is intended to produce a result that appears to humans to be of high quality (as opposed to doing well on basic objective measures, such as PSNR). So I'll use it

## [Multipass encoding](https://gitlab.com/AOMediaCodec/SVT-AV1/-/blob/master/Docs/CommonQuestions.md#multi-pass-encoding)
PSY people suggest not to encode the same video multiple times. This is a common mistake made by people new to video encoding. Every time you encode a video, you lose additional quality due to generation loss. This is because video codecs are lossy, and every time you encode a video, you lose more information. This is why it is important to keep the original video file if you frequently re-encode it.

AV1 people says some encoder features benefit from or require the use of a multi-pass encoding approach. In SVT-AV1, in general, multi-pass encoding is useful for achieving a target bitrate when using VBR (variable bit rate) encoding, although both one-pass and multi-pass modes are supported.

When using CRF (constant visual rate factor) mode, multi-pass encoding is designed to improve quality for corner case videos--it is particularly helpful in videos with high motion because it can adjust the prediction structure (to use closer references, for example). Multi-pass encoding, therefore, can be said to have an impact on quality in CRF mode, but is not critical in most situations. In general, multi-pass encoding is not as important for SVT-AV1 in CRF mode than it is for some other encoders.

CBR (constant bit rate) encoding is always one-pass.

I won't use multipass encoding then.

## [Select the audio codec](https://jellyfin.org/docs/general/clients/codec-support/#audio-compatibility)
If the audio codec is unsupported or incompatible (such as playing a 5.1 channel stream on a stereo device), the audio codec must be transcoded. This is not nearly as intensive as video transcoding.

When comparing audio encodings from a **compatibility** and **open-source** perspective, here are the key aspects to consider:

### MP3 (MPEG-1 Audio Layer III)

#### Compatibility
- **Highly Compatible**: Supported on virtually all devices and platforms, including legacy systems.
- **Wide Adoption**: Default choice for audio streaming, portable devices, and browsers.

#### Open Source
- **Patented (Previously)**: MP3 was heavily patented until 2017. After patent expiration, it is now open for unrestricted use.
- **Decoders/Encoders**: Open-source implementations exist (e.g., `LAME`), but the format's history with patents may make some projects hesitant.

### AAC (Advanced Audio Codec)

#### Compatibility
- **Widely Compatible**: Supported on most modern devices and platforms, including smartphones, streaming services, and browsers.
- **Less Legacy Support**: Older devices may not support AAC compared to MP3.

#### Open Source
- **Partially Proprietary**: AAC is still patent-encumbered, requiring licensing for certain use cases.
- **Limited Open Implementations**: While open-source decoders like `FAAD` exist, licensing concerns can restrict adoption.

### Opus

#### Compatibility
- **Growing Adoption**: Supported by major browsers (via WebRTC), VoIP platforms (e.g., Zoom, Discord), and some hardware devices.
- **Not Universally Supported**: Fewer consumer devices support Opus natively compared to MP3/AAC.
- But jellyfin's compatible table shows that it does have good compatibility already

#### Open Source
- **Fully Open Source**: Created by the Xiph.Org Foundation and standardized by IETF as an open format.
- **Royalty-Free**: No patent restrictions, making it ideal for open-source projects and licensing-sensitive environments.

### Vorbis

#### Compatibility
- **Limited Adoption**: Compatible with platforms that support Ogg containers, such as many Linux-based systems, but lacks broad support on consumer devices (e.g., smartphones, car stereos).
- **Niche Use**: Often used in gaming and certain open-source projects.

#### Open Source
- **Fully Open Source**: Also by Xiph.Org, Vorbis is royalty-free and patent-unencumbered.
- **Less Modern**: Lacks the efficiency and versatility of Opus.

### FLAC (Free Lossless Audio Codec)

#### Compatibility
- **Good Adoption**: Supported on most modern devices, but not universally (e.g., some older car stereos or basic devices).
- **Lossless Focus**: Typically used in archival and audiophile applications, rather than streaming or portable audio.

#### Open Source
- **Fully Open Source**: Another Xiph.Org project, FLAC is royalty-free and widely used in open-source ecosystems.
- **High Integrity**: Preferred for open-source projects requiring exact replication of audio data.

### Summary Table

| Format  | Compatibility              | Open Source Status            | Notes                                        |
|---------|----------------------------|--------------------------------|---------------------------------------------|
| **MP3** | Ubiquitous                 | Open after 2017               | Excellent legacy and modern support.        |
| **AAC** | Broad (modern only)        | Partially proprietary         | Better efficiency than MP3; patent-encumbered. |
| **Opus**| Growing (modern)           | Fully open source             | Best for VoIP, streaming; highly efficient. |
| **Vorbis** | Limited (niche)         | Fully open source             | Predecessor of Opus; less efficient.        |
| **FLAC** | Good (lossless niche)     | Fully open source             | Ideal for archival and audiophile use.      |

### Conclusion

I doubted between flac and opus, but given that I want to reduce disk space I'd go with opus.

`-c:a libopus`

## Select the audio bitrate

The Opus codec is highly efficient and flexible, with settings that can be adjusted depending on your specific use case (e.g., speech, music, or general-purpose audio).

Bitrate (`-b:a`) suggested values are:
- **Speech**: 16–32 kbps.
- **Music**: 64–128 kbps.
- **General-purpose**: 48–96 kbps.
- For high-quality music or critical listening: 128–256 kbps.

Typical values are 128 or 192 kbps. The file size will change, but the difference might not be as dramatic as you might expect, especially with Opus.

So, for a **1-minute audio file**:
- At **128 kbps**, the file size would be around **960 KB**.
- At **192 kbps**, the file size would be around **1.44 MB**.

This means the file size increases by about **50%** when you increase from 128 kbps to 192 kbps. For a 3h movie it would be 259MB at 192 and 173MB at 128, so there is not much difference

- **128 kbps** will still provide a good balance of quality for most use cases, particularly for spoken audio or general movie soundtracks where the main focus is not the high-fidelity music or sound effects.
- **192 kbps** will offer a noticeable increase in quality, especially for music and sound effects in movies, but the file size increase is moderate compared to the improvement in audio quality.

So, if you are looking for better quality and are okay with the slightly larger file size, 192 kbps is a good choice and the increase in size is not that noticeable.

I'll then use `-b:a 192k`. Be careful to set it because `ffmpeg` default value is 96kbps which is way too low.

## Select the video container
### Decide whether to use mkv or mp4

MP4 (MPEG-4 Part 14):

1. Characteristics
  - Closed sourced
  - Developed by MPEG group
  - Widely supported across devices
  - Smaller file size
  - Preferred for streaming platforms
  - Standard for web and mobile video
  - Not truly open source
  - Controlled by MPEG LA (Licensing Administration)
  - Requires patent licensing for commercial use
  - Royalty-based format
  - Closed technical specifications
  - Limited by patent restrictions

2. Technical Details
  - Limited to specific codecs
  - Better compression
  - Simpler metadata support
  - Lower overhead
  - Maximum file size of 4GB

MKV (Matroska Video):
1. Characteristics
  - Open-source container format
  - Highly flexible
  - Supports virtually unlimited tracks
  - No practical file size limitations
  - Better for complex multimedia content
  - Fully open-source standard
  - Free and open-source software (FOSS)
  - No licensing fees
  - Open technical specifications
  - Community-driven development
  - Uses Creative Commons licensing
  - Maintained by the Matroska Open Source project
  - Completely royalty-free

2. Technical Details
  - Supports multiple audio/subtitle tracks
  - Can include chapters
  - Supports virtually any codec
  - More metadata capabilities
  - Larger file sizes
  - Lossless audio/video preservation

Comparison Points:

From an open-source perspective, MKV is significantly more aligned with open-source principles and provides maximum flexibility for developers and users.

Compatibility:
- MP4: Highest device/platform support
- MKV: Less universal, requires specific players

Codec Support:
- MP4: Limited (H.264, AAC primarily)
- MKV: Virtually unlimited

Use Cases:
- MP4: Streaming, mobile, web
- MKV: Archiving, high-quality collections, complex multimedia

Recommended Usage:
- MP4: Sharing, streaming, compatibility
- MKV: Archival, preservation, complex multimedia projects

Performance:
- MP4: Faster processing, smaller size
- MKV: More flexible, potentially larger size

### MKV vs TS 

**TS (Transport Stream)** and **MKV (Matroska)** are two different video container formats, each designed for specific use cases. Here’s a detailed comparison:

TS is one of the primary containers for streaming for Jellyfin.

#### **Purpose and Use Case**
| **Aspect**              | **TS**                                 | **MKV**                                  |
|--------------------------|-----------------------------------------|------------------------------------------|
| **Primary Use**          | Designed for broadcasting and streaming (e.g., live TV, IPTV). | Versatile container for storage and playback of multimedia files. |
| **Streaming**            | Optimized for real-time streaming; handles packet loss well. | Less optimized for live streaming, better for local storage and playback. |
| **Editing/Archiving**    | Less suitable for editing or archiving. | Popular for editing, archiving, and general media distribution. |

#### **Technical Differences**
| **Aspect**              | **TS**                                 | **MKV**                                  |
|--------------------------|-----------------------------------------|------------------------------------------|
| **Structure**            | Packet-based (fixed 188-byte packets). | Flexible and extensible structure.       |
| **Codec Support**        | Limited (commonly MPEG-2, H.264).      | Broad codec support (H.264, H.265, VP9, AV1, FLAC, etc.). |
| **Error Resilience**     | Designed to handle errors in transmission (e.g., packet loss). | No native error handling for streaming.  |
| **Metadata Support**     | Limited.                              | Rich metadata support (subtitles, chapters, tags). |

#### **Features**
| **Aspect**              | **TS**                                 | **MKV**                                  |
|--------------------------|-----------------------------------------|------------------------------------------|
| **File Size Overhead**   | Slightly larger due to packetized structure. | Efficient, with minimal overhead.        |
| **Subtitles**            | Limited (basic support for teletext or DVB subtitles). | Comprehensive (supports SRT, ASS, PGS, etc.). |
| **Chapters**             | No native support.                    | Full support for chapter markers.        |
| **Compatibility**        | Widely supported in streaming and broadcast systems. | Widely supported in media players.       |

#### **Pros and Cons**

##### **TS (Transport Stream)**
Pros:
- Ideal for **real-time streaming** (e.g., live TV, IPTV).
- Handles **packet loss** effectively.
- Simple and efficient for broadcast systems.

Cons:
- Limited codec and metadata support.
- Less efficient for storage (higher overhead).
- Poor support for advanced features like subtitles and chapters.

##### **MKV (Matroska)**
Pros:
- Highly **versatile** and feature-rich.
- Supports almost any modern codec and **advanced features** like chapters, subtitles, and rich metadata.
- Efficient for **storage and playback**.

Cons:
- Not optimized for real-time streaming.
- Slightly more complex structure, which might increase processing overhead.

#### **When to Use Which?**
- **Use TS**:
 - For **live streaming**, broadcast applications, or situations where error resilience is critical.
 - When the source content is already in TS format (e.g., recorded TV streams).

- **Use MKV**:
 - For **local storage**, playback, or archiving of multimedia files.
 - When advanced features like **subtitles, chapters, and multiple audio tracks** are needed.
 - For transcoding or converting video into a more flexible and efficient format.

### Conclusion

I'll use mkv although there is a [compatibility issue with most common browsers](https://jellyfin.org/docs/general/clients/codec-support/#container-compatibility) as neither Chrome nor Firefox nor Safari supports it, this will result in remuxing. The video and audio codec will remain intact but wrapped in a supported container. This is the least intensive process. Most video containers will be remuxed to use the HLS streaming protocol and TS containers. Remuxing shouldn't be a concern even for an RPi3.

It makes then sense to store it in mkv and let jellyfin remux it to TS.

## [Select the subtitle format](https://jellyfin.org/docs/general/clients/codec-support/#container-compatibility)
Subtitles can be a subtle issue for transcoding. Containers have a limited number of subtitles that are supported. If subtitles need to be transcoded, it will happen one of two ways: they can be converted into another format that is supported, or burned into the video due to the subtitle transcoding not being supported. Burning in subtitles is the most intensive method of transcoding. This is due to two transcodings happening at once; applying the subtitle layer on top of the video layer.

### Decide whether to use SRT or ASS for your subtitles

Here's a comparison of ASS (Advanced SubStation Alpha) and SRT (SubRip Text) subtitle formats:

ASS: Advanced formatting capabilities
- Complex styling options
- Supports multiple text colors within same subtitle
- Allows advanced positioning
- Supports animations and special effects
- Can include font styles, sizes, and colors
- Supports karaoke-style text highlighting

SRT: Simple, basic formatting
- Plain text subtitles
- Limited styling options
- Basic positioning
- Primarily used for text translation
- Widely compatible across media players
- Simple structure with timecodes and text

Technical Differences:
- ASS: More complex XML-like file structure
- SRT: Simple comma-separated text format

Usage Scenarios:
- ASS: Anime, complex video subtitles, professional translations
- SRT: General video subtitles, simple translations, broad compatibility

File Size:
- ASS: Larger due to extensive formatting information
- SRT: Smaller, more compact

Compatibility:
- ASS: Limited to specific media players
- SRT: Near-universal support across platforms

Recommendation:
- Use SRT for simplicity and compatibility
- Use ASS for advanced styling and professional subtitle work

### Decide whether to extract the subtitles from the video file

The choice between embedding subtitles within the file or keeping them as external `.srt` files depends on your specific needs, including convenience, compatibility, and flexibility. Here’s a breakdown of the advantages and disadvantages of each approach:

#### Embedded Subtitles
Subtitles are included directly in the container file (e.g., MKV) as a separate track.

##### Advantages
1. **Convenience**:
   - All components (video, audio, subtitles) are stored in a single file, reducing the risk of losing or misplacing subtitle files.
2. **Portability**:
   - Easier to share or move files without worrying about transferring separate subtitle files.
3. **Compatibility**:
   - Modern media players (e.g., VLC, MPV, Plex) handle embedded subtitles well, ensuring smooth playback.
4. **Advanced Features**:
   - Supports advanced formats (e.g., ASS, SSA) with styled text, positioning, and effects.
5. **Preservation**:
   - Archival purposes benefit from keeping subtitles alongside the video for long-term consistency.

##### Disadvantages
1. **Flexibility**:
   - Harder to edit or replace subtitles without remuxing the file.
2. **Compatibility Issues**:
   - Some older or less capable devices might not support embedded subtitles.
3. **File Size**:
   - May slightly increase the file size, though the impact is usually minimal.

#### External Subtitles
Subtitles are stored as separate `.srt`, `.ass`, or other subtitle files alongside the video file.

##### Advantages
1. **Flexibility**:
   - Easy to edit, replace, or update subtitles without altering the video file.
2. **Device Compatibility**:
   - Some players and devices may prefer or require external subtitle files.
3. **Smaller File Size**:
   - The video file remains slightly smaller without the subtitle track.
4. **Multilingual Support**:
   - Easier to provide multiple subtitle files in different languages without duplicating the video file.

##### Disadvantages
1. **Organization**:
   - Managing separate files can be cumbersome, especially with large libraries.
2. **Risk of Loss**:
   - Subtitles may become separated or lost over time if not managed properly.
3. **Limited Features**:
   - Basic formats like `.srt` lack advanced styling and formatting options.

#### Which Is Better?

##### Use Embedded Subtitles If
- You want a **single, portable file** for simplicity and sharing.
- You are archiving your media for **long-term use** and want to preserve all components together.
- The subtitles use advanced formatting (e.g., ASS, SSA) or are graphical (e.g., PGS from Blu-rays).

##### Use External Subtitles If
- You need to **edit, replace, or add subtitles** frequently.
- You want to support multiple subtitle languages for the same video.
- Compatibility with older devices or specific use cases requires it.

### Conclusion

I'll use SRT as the subtitles format as it's the simplest and most widely supported subtitle format. They won't be embedded into the video file for easier post-processing with Bazarr. So I'll configure the unmanic conversion from ASS to SRT and subtitle extraction steps.

Even if TS doesn't support SRT I think that jellyfin handles this well.

As I'm going to extract the subtitles with unmanic in a posterior step, I'm going to copy the subtitles streams directly in the transcoding `-c:s copy`. I saw that if you don't set it by default ffmpeg will convert embedded srt to ass, that would mean that in the transcoding I'll convert srt to ass and then in the unmanic post step it will move back to srt, which doesn't make sense.
Read more at [1](https://www.reddit.com/r/jellyfin/comments/qvb5k6/which_is_the_best_format_for_subtitles/). If you want to extract some subtitles from the mkv you can use [this script](https://gist.github.com/majora2007/724354d081627cfd96c24b8eefef4ec3)

## Decide whether to use HDR or SDR 


When the source video is in HDR, it will need to be tone-mapped to SDR when transcoding, as [Jellyfin currently doesn't support HDR to HDR tone-mapping](https://jellyfin.org/docs/general/server/transcoding/#hdr-to-sdr-tone-mapping), or passing through HDR metadata. While this can be done in software, it is very slow, and you may encounter situations where no modern consumer CPUs can transcode in real time. Therefore, a GPU is always recommended, where even a basic Intel iGPU can handle as much load as a Ryzen 5800X for this usecase.

To check if my library contains many files that use HDR I've used this script:

```python
#!/usr/bin/env python3
import os
import subprocess
import sys

# Define the video file extensions to look for
VIDEO_EXTENSIONS = {".mkv", ".mp4", ".avi", ".mov", ".wmv", ".flv"}


# Initialize counters
def process_directory(root_path):
    total_files = 0
    hdr_files = []

    # Function to check if a file has HDR metadata
    def check_hdr(file_path):
        try:
            # Run ffprobe and capture output
            result = subprocess.run(
                ["ffprobe", "-i", file_path, "-hide_banner"],
                stderr=subprocess.PIPE,
                stdout=subprocess.PIPE,
                text=True,
            )
            # Search for HDR-related metadata
            output = result.stderr + result.stdout
            if any(
                keyword in output
                for keyword in [
                    "color_primaries",
                    "transfer_characteristics",
                    "HDR_metadata",
                ]
            ):
                return True
        except Exception as e:
            print(f"Error checking file {file_path}: {e}")
        return False

    # Walk through all directories and subdirectories
    for root, _, files in os.walk(root_path):
        for file in files:
            # Check if the file has a valid video extension
            if os.path.splitext(file)[1].lower() in VIDEO_EXTENSIONS:
                total_files += 1
                file_path = os.path.join(root, file)
                print(f"Checking {file_path}")

                # Check for HDR metadata
                if check_hdr(file_path):
                    hdr_files.append(file_path)

    # Display results
    hdr_count = len(hdr_files)
    if total_files > 0:
        hdr_percentage = (hdr_count / total_files) * 100
    else:
        hdr_percentage = 0

    print("\nSummary for:", root_path)
    print(f"Total video files checked: {total_files}")
    print(f"Files with HDR metadata: {hdr_count}")
    print(f"Percentage of HDR files: {hdr_percentage:.2f}%")

    # List all HDR files
    if hdr_files:
        print("\nHDR Files:")
        for hdr_file in hdr_files:
            print(hdr_file)


# Main script
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <root_path1> [<root_path2> ...]")
        sys.exit(1)

    for path in sys.argv[1:]:
        if os.path.exists(path) and os.path.isdir(path):
            process_directory(path)
        else:
            print(f"Invalid path: {path}")
```

In my library I had no file that matched the HDR check above, so I guess I don't need it

## Decide the number of workers

I've seen that with just one worker my 16 CPU threads are fully utilised, so it looks that it makes no sense to increase the worker numbers, but [people suggest](https://www.reddit.com/r/Tdarr/comments/1cv1826/optimal_amount_of_workers/) to use at least two because even if it halves the fps, as there's an efficiency gain because after a transcode completes, it has to move it off the temp cache area, load in the next file, etc. The parallel transcode will just increase in usage until the first worker is transcoding again, and vice versa. 

[Unmanic documentation](https://docs.unmanic.app/docs/configuration/workers_settings/) suggest to start with one worker initially, and then increase this value slowly until you find the right balance of system resource use and task processing speed. They also say that for most people, there is no benefit to running more than 3-5 workers. Depending on the type of tasks you carry out, you may find diminishing returns increasing this value beyond 5.

You can set schedules to pause and resume workers. This can be interesting if you want to only do transcoding when electricity is cheaper, or stop it when you need the CPU for example if you give service to other users and they have spikes in the resource consumption.

In my case I'm going to use 3 workers the 24h until I solve the space issue I'm currently facing, and afterwards I'll only do it when the electricity is cheap.

# Transcoding tools comparison

- [Unmanic](unmanic.md): open source
- Tdarr: closed sourced
- Handbrake: ([home](https://handbrake.fr/), [source](https://github.com/HandBrake/HandBrake))
- [ab-av1](https://github.com/alexheretic/ab-av1)
- [FileFlows](https://fileflows.com/)

I ended up using [unmanic](unmanic.md).

Read more about the comparison of tools on [1](https://wiki.x266.mov/blog/av1-for-dummies), [2](https://www.reddit.com/r/opensource/comments/1aoxloh/comment/kr4ehvc/)

# Troubleshooting


## Input channel layout 5.1(side) detected, side channels will be mapped to back channels.

Don't worry you won't loose the 5.1, it will just transform from 5.1(side) to 5.1

# References

- [AV1 for dummies](https://wiki.x266.mov/blog/av1-for-dummies)
- [AOMediaCodec guide](https://gitlab.com/AOMediaCodec/SVT-AV1/-/blob/master/Docs/Ffmpeg.md)
- [AV1 FAQ](https://gitlab.com/AOMediaCodec/SVT-AV1/-/blob/master/Docs/CommonQuestions.md#what-presets-do)
- [Analysis on parameters for animation](https://wiki.x266.mov/blog/svt-av1-deep-dive#early-tldr-on-parameters-results)
- [Jellyfin megathread on AV1 configuration](https://forum.jellyfin.org/t-encoding-discussion-megathread-ffmpeg-handbrake-av1-etc)
- [SVT-AV1 parameter reference](https://gitlab.com/AOMediaCodec/SVT-AV1/-/blob/master/Docs/Parameters.md)
- [ffmpeg AV1 configuration reference](https://trac.ffmpeg.org/wiki/Encode/AV1)
- [Video encoding guide to AV1](https://forum.level1techs.com/t/video-encoding-to-av1-guide-wip/199694)
- [Comparison between x265 and AV1](https://www.free-codecs.com/guides/is-av1-better-than-h-265.htm)
