import os

# Files to merge in order
input_files = [
    r"c:\Projectbulid\manuscript\Introduction_v3_draft.md",
    r"c:\Projectbulid\manuscript\Methods_v3_draft.md",
    r"c:\Projectbulid\manuscript\Results_v3_standalone.md",
    r"c:\Projectbulid\manuscript\Discussion_v2_expanded.md",
    r"c:\Projectbulid\manuscript\References_complete_1_48.md"
]

output_file = r"c:\Projectbulid\manuscript\Manuscript_FINAL_Submission.md"
merged_draft = r"c:\Projectbulid\manuscript\manuscript_v3_fully_merged_draft.md"

def extract_abstract(filepath):
    # Extract Title and Abstract up to the "## 1. Introduction" line
    abstract_text = ""
    with open(filepath, 'r', encoding='utf-8') as f:
        for line in f:
            if line.startswith("## 1. Introduction"):
                break
            abstract_text += line
    return abstract_text

def merge_files():
    with open(output_file, 'w', encoding='utf-8') as outfile:
        # 1. Write the Abstract and Title first
        try:
            abstract = extract_abstract(merged_draft)
            outfile.write(abstract)
            outfile.write("\n\n")
        except Exception as e:
            print(f"Failed to read abstract: {e}")
        
        # 2. Append the user's specific files
        for file in input_files:
            try:
                with open(file, 'r', encoding='utf-8') as infile:
                    content = infile.read()
                    outfile.write(content)
                    outfile.write("\n\n---\n\n")
            except Exception as e:
                print(f"Failed to read {file}: {e}")

if __name__ == "__main__":
    merge_files()
    print(f"Successfully generated {output_file}!")
