// N8n Function Node: Fetch Transcript with Timestamps
const { YoutubeTranscript } = require('youtube-transcript');

async function getVideoId(url) {
  const regex = /(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/;
  const match = url.match(regex);
  return match ? match[1] : null;
}

function formatDuration(seconds) {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const remainingSeconds = Math.floor(seconds % 60);

  if (hours > 0) {
    return `${hours}:${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`;
  }

  return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
}

async function execute(videoUrl) {
  try {
    const videoId = await getVideoId(videoUrl);

    if (!videoId) {
      throw new Error('Invalid YouTube URL');
    }

    const transcriptArray = await YoutubeTranscript.fetchTranscript(videoId);

    const fullTranscriptWithTime = transcriptArray
      .map((item) => `[${formatDuration(item.offset / 1000)}] ${item.text}`)
      .join('\n');

    const plainTranscript = transcriptArray
      .map((item) => item.text)
      .join(' ')
      .trim();

    return {
      json: {
        success: true,
        video_id: videoId,
        transcript: plainTranscript,
        transcript_with_timestamps: fullTranscriptWithTime,
        segments: transcriptArray,
      },
    };
  } catch (error) {
    return {
      json: {
        success: false,
        error: error.message,
        video_url: videoUrl,
      },
    };
  }
}

return await execute($input.first().json.body.video_url);
