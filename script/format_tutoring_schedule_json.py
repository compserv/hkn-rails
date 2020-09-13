import json, os


mapping_fn = lambda n: n - 120  # Shifts all of the keys 121-->180 to 1-->60

with open("zxywvu.txt", "r+") as file:
    data = json.loads(file.readlines()[0])
    new_data = {str(mapping_fn(int(key))): val for key, val in data.items()}
    file.seek(0)
    new_line = file.write(json.dumps(new_data))
    file.truncate()
