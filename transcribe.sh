#!/bin/bash

cleanup() {
    rm tmp*
}

cleanup

for m4a_file in *.m4a; do
    if [ -f "$m4a_file" ]; then
    
    	# split
        echo "Splitting $m4a_file..."
        ffmpeg -i "$m4a_file" -f segment -segment_time 10 -c copy -map 0 -reset_timestamps 1 "tmp_%03d.m4a"
        echo "Done."

        # Transcribe and save each segment
        segment_count=0
        total_segments=$(ls "tmp_"*.m4a | wc -l)
        
        for segment_file in "tmp_"*.m4a; do
            # Convert .m4a to .wav
            echo "Converting $segment_file to wav..."
            wav_file="tmp_$(printf "%03d" "$segment_count").wav"
            ffmpeg -i "$segment_file" -acodec pcm_s16le -ar 16000 "$wav_file"
            echo "Done."

            # Display progress bar
            percentage=$((100 * segment_count / total_segments))
            printf "Progress: [%-20s] %d%%\r" '=>' "$percentage"

            # Transcribe
            temp_transcription_file="tmp_$(printf "%03d" "$segment_count").txt"
            python3 transcribewav.py --input "$wav_file" > "$temp_transcription_file"
            ((segment_count++))
        done

        echo -e "\nTranscription completed for $m4a_file."

        # Merge all the temporary transcription files into a single file
        merged_transcription_file="${m4a_file%.m4a}_$(date +"%Y%m%d%H%M%S").txt"
        cat "tmp_"*.txt > "$merged_transcription_file"
        echo "Merged transcriptions saved to $merged_transcription_file"

        # Cleanup
        cleanup
    fi
done
