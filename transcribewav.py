import argparse
import os
import datetime
import speech_recognition as sr
from pydub import AudioSegment

def transcribe_audio(audio_file):
    recognizer = sr.Recognizer()

    with sr.AudioFile(audio_file) as source:
        audio_data = recognizer.record(source)

    try:
        text = recognizer.recognize_google(audio_data, language="el-GR")
        return text
    except sr.UnknownValueError:
        return None
    except sr.RequestError as e:
        print(f"Error: {e}")
        return None

def get_audio_duration(audio_file):
    audio = AudioSegment.from_file(audio_file)
    return audio.duration_seconds

def main():
    parser = argparse.ArgumentParser(description="Transcribe audio file.")
    parser.add_argument("--input", required=True, help="Input audio file path")
    args = parser.parse_args()

    audio_file = args.input
    transcription = transcribe_audio(audio_file)

    if transcription:
        print("\nTranscription:", transcription)
    else:
        print("\nTranscription failed.")

    # Create output file name based on input file and current date
    file_name, file_extension = os.path.splitext(os.path.basename(audio_file))
    current_date = datetime.datetime.now().strftime("%Y%m%d%H%M%S%f")[:-3]
    output_file_name = f"{file_name}_{current_date}.txt"

    with open(output_file_name, "w") as output_file:
        output_file.write(f"{transcription}")

if __name__ == "__main__":
    main()

