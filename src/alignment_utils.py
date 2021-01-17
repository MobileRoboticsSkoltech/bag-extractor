import os


def align(time_ref, target_dir):
    with open(time_ref, 'r') as time_ref_file:
        values = time_ref_file.readline().split(',')
        seq = int(values[0])
        timestamp = int(values[1])
        time_ref = int(values[2])
        delta = time_ref - timestamp

        print("Aligning with sequence %d, timestamps %d %d" % (seq, timestamp, time_ref))
        for filename in os.listdir(target_dir):
            old_name = filename.split('.')[0]
            extension = filename.split('.')[1]
            new_name = str(int(old_name) - delta)
            print("Old name: %s new name: %s" % (filename, new_name))
            os.rename(
                os.path.join(target_dir, filename),
                os.path.join(target_dir, new_name + "." + extension)
            )

            # TODO: output csv with <old_ts, new_ts>
