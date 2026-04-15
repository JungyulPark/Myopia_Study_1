import sys
import zipfile
import xml.etree.ElementTree as ET

def extract(path, out_path):
    try:
        doc = zipfile.ZipFile(path)
        xml_content = doc.read('word/document.xml')
        doc.close()
        tree = ET.XML(xml_content)
        WORD_NAMESPACE = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
        PARA = WORD_NAMESPACE + 'p'
        TEXT = WORD_NAMESPACE + 't'
        
        paragraphs = []
        for paragraph in tree.iter(PARA):
            texts = [node.text for node in paragraph.iter(TEXT) if node.text]
            if texts:
                paragraphs.append(''.join(texts))
        with open(out_path, "w", encoding="utf-8") as f:
            f.write('\n'.join(paragraphs))
    except Exception as e:
        with open(out_path, "w", encoding="utf-8") as f:
            f.write(str(e))

if __name__ == '__main__':
    extract(sys.argv[1], sys.argv[2])
