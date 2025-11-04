import requests
import os

# Define the URLs for each shruti type
tanpura_urls = {
    'pa': {
        'C': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/pa-tanpura-c3-60-bpm_1.wav',
        'C#': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/pa-tanpura-c-hash-3-60-bpm_1.wav',
        'D': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/pa-tanpura-d3-60-bpm_1.wav',
        'D#': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/pa-tanpura-d-hash-3-60-bpm_1.wav',
        'E': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/pa-tanpura-e3-60-bpm_1.wav',
        'F': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/pa-tanpura-f3-60-bpm_1.wav',
        'F#': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/pa-tanpura-f-hash-3-60-bpm_1.wav',
        'G': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/pa-tanpura-g3-60-bpm_1.wav',
        'G#': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/pa-tanpura-g-hash-3-60-bpm_1.wav',
        'A': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/pa-tanpura-a3-60-bpm_1.wav',
        'A#': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/pa-tanpura-a-hash-3-60%20bpm_1.wav',
        'B': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/pa-tanpura-b3-60-bpm_1.wav'
    },
    'ma': {
        'C': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ma-tanpura-c3-60-bpm_1.wav',
        'C#': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ma-tanpura-c-hash-3-60-bpm_1.wav',
        'D': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ma-tanpura-d3-60-bpm_1.wav',
        'D#': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ma-tanpura-d-hash-3-60-bpm_1.wav',
        'E': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ma-tanpura-e3-60-bpm_1.wav',
        'F': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ma-tanpura-f3-60-bpm_1.wav',
        'F#': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ma-tanpura-f-hash-3-60-bpm_1.wav',
        'G': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ma-tanpura-g3-60-bpm_1.wav',
        'G#': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ma-tanpura-g-hash-3-60-bpm_1.wav',
        'A': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ma-tanpura-a3-60-bpm_1.wav',
        'A#': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ma-tanpura-a-hash-3-60-bpm_1.wav',
        'B': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ma-tanpura-b3-60-bpm_1.wav'
    },
    'ni': {
        'C': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ni-tanpura-c3-60-bpm_1.wav',
        'C#': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ni-tanpura-c-hash-3-60-bpm_1.wav',
        'D': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ni-tanpura-d3-60-bpm_1.wav',
        'D#': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ni-tanpura-d-hash-3-60-bpm_1.wav',
        'E': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ni-tanpura-e3-60-bpm_1.wav',
        'F': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ni-tanpura-f3-60-bpm_1.wav',
        'F#': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ni-tanpura-f-hash-3-60-bpm_1.wav',
        'G': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ni-tanpura-g3-60-bpm_1.wav',
        'G#': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ni-tanpura-g-hash-3-60-bpm_1.wav',
        'A': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ni-tanpura-a3-60-bpm_1.wav',
        'A#': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ni-tanpura-a-hash-3-60-bpm_1.wav',
        'B': 'https://api.artiumacademy.com/tanpura-files/tanpura-new-files/ni-tanpura-b3-60-bpm_1.wav'
    }
}

def download_file(url, filename):
    """Download a file from URL and save it with the given filename"""
    try:
        print(f"Downloading {filename}...")
        response = requests.get(url, stream=True)
        response.raise_for_status()
        
        with open(filename, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        print(f"✓ Successfully downloaded {filename}")
        return True
    except Exception as e:
        print(f"✗ Error downloading {filename}: {str(e)}")
        return False

def main():
    # Create output directory if it doesn't exist
    output_dir = "tanpura_files"
    os.makedirs(output_dir, exist_ok=True)
    
    total_files = 0
    successful_downloads = 0
    
    # Download all files
    for shruti_type, notes in tanpura_urls.items():
        for note, url in notes.items():
            filename = os.path.join(output_dir, f"{note}-{shruti_type}.wav")
            total_files += 1
            if download_file(url, filename):
                successful_downloads += 1
    
    print(f"\n{'='*50}")
    print(f"Download complete!")
    print(f"Successfully downloaded: {successful_downloads}/{total_files} files")
    print(f"Files saved in: {output_dir}/")
    print(f"{'='*50}")

if __name__ == "__main__":
    main()