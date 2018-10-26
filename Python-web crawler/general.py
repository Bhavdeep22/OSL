import os


# create folder for each website
def create_project_dir(directory):
    if not os.path.exists(directory):
        print('Creating directory ' + directory)
        os.makedirs(directory)


# Make queue and crawl files for each folder if it is not created
def create_data_files(project_name, base_url):
    q = os.path.join(project_name , 'queue.txt')
    c = os.path.join(project_name,"crawled.txt")
    if not os.path.isfile(q):
        write_file(q, base_url)
    if not os.path.isfile(c):
        write_file(c, '')


# Create a new file
def write_file(path, data):
    with open(path, 'w') as f:
        f.write(data)


# Append data onto existing file
def append_to_file(path, data):
    with open(path, 'a') as file:
        file.write(data + '\n')


# Delete the contents of a file
def delete_file_contents(path):
    open(path, 'w').close()


# Read a file and convert each line to set items
def file_to_set(file_name):
    results = set()
    with open(file_name, 'rt') as f:
        for line in f:
            results.add(line.replace('\n', ''))
    return results


# Iterate through a set, each item will be a line in a file
def set_to_file(links, file_name):
    with open(file_name,"w") as f:
        for l in sorted(links):
            f.write(l+"\n")
