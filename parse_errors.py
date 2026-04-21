import sys
import re

def parse_errors(filename):
    with open(filename, 'r') as f:
        content = f.read()

    # Split by the level markers (error, info, warning)
    # The format seems to be:
    #   error • message •
    #          path:line:col •
    #          error_code
    
    # We can try to find blocks that start with "  error •"
    blocks = content.split('\n  error •')
    
    errors = []
    for block in blocks[1:]: # Skip the first part which is before the first error
        lines = block.strip().split('\n')
        if not lines:
            continue
            
        # Message is on the first line (or multiple lines until the path)
        message_part = ""
        path_line = ""
        code_line = ""
        
        i = 0
        while i < len(lines) and " •" not in lines[i]:
             message_part += " " + lines[i].strip()
             i += 1
        
        if i < len(lines):
            message_part = lines[0].split(' •')[0].strip()
            
        # The path is usually on the next non-empty line, or part of the first if it's compact
        # But based on the head output:
        #   error • message •
        #          path:line:col •
        #          error_code
        
        remaining = "\n".join(lines)
        match = re.search(r'•\s*(.*?\.dart):(\d+):\d+\s*•\s*(\w+)', block, re.DOTALL)
        if match:
             file_path = match.group(1).strip()
             line_num = match.group(2).strip()
             error_code = match.group(3).strip()
             message = lines[0].split(' •')[0].strip()
             errors.append({
                 'file': file_path,
                 'line': line_num,
                 'code': error_code,
                 'message': message
             })

    # Group by file
    grouped = {}
    for err in errors:
        grouped.setdefault(err['file'], []).append(err)
        
    for file, errs in grouped.items():
        print(f"File: {file}")
        for e in errs:
            print(f"  Line {e['line']} [{e['code']}]: {e['message']}")

if __name__ == "__main__":
    parse_errors(sys.argv[1])
