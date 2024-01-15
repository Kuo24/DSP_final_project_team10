import librosa.display
import csv
import os

def gen_csv(chosen_music):
    # Load the vocals file
    vocals_file = os.path.join('./output./', chosen_music, '{}_vocals.wav'.format(chosen_music))
    print(vocals_file)
    audio, samplerate=librosa.load(vocals_file)

    # Use the pyin function from Librosa for fundamental frequency (pitch) estimation
    f0, voiced_flag, voiced_probs = librosa.pyin(audio, fmin=librosa.note_to_hz('C2'), fmax=librosa.note_to_hz('C7'))

    # Iterate through every point and set pitch to 0 where amplitude is less than 0.01
    for i in range(len(f0)-1):
        if audio[librosa.frames_to_samples(i)] < 0.01:
            f0[i] = 0

    # Save time axis and pitch data to CSV
    csv_file = '{}_pitch_data.csv'.format(chosen_music)
    with open(csv_file, 'w', newline='') as csvfile:
        csvwriter = csv.writer(csvfile)
        csvwriter.writerow(['Time', 'Frequency'])
        for time, frequency in zip(librosa.frames_to_time(range(len(f0))), f0):
            csvwriter.writerow([time, frequency])

# Choose a song to generate csv file
while True:
    chosen_music = input('Please choose a song (music1, music2, music3) : ')
    if chosen_music in ['music1','music2','music3']:
        gen_csv(chosen_music)
        break
    else:
        print('There does not exist {}'.format(chosen_music))