import os
import csv


def align(time_ref, target_dir, ref_seq):
    """Aligns timestamps of the files in the given directory.
       Writes transformation meta information to _transformation_metainf.csv file.

        Args:
            time_ref: Time reference file with timestamps from another source
            target_dir: Target directory that contains files (e.g. images) with timestamps as filenames
            ref_seq: Sequence from time reference file that matches the time of the first image
    """
    with open(time_ref, 'r') as time_ref_file:
        values = time_ref_file.readlines()[ref_seq - 1].split(',')
        seq = int(values[0])
        ref_timestamp = int(values[1])
        # get list of filenames with timestamps
        filename_timestamps = map(lambda x: int(x.split('.')[0]), os.listdir(target_dir))
        filename_timestamps.sort()
        extension = os.listdir(target_dir)[0].split('.')[1]
        timestamp = filename_timestamps[0]
        # obtain delta with the first filename timestamp and reference timestamp
        delta = ref_timestamp - timestamp

        print("Aligning with sequence %d, timestamps %d - %d" % (seq, timestamp, ref_timestamp))

        with open(os.path.join(target_dir, '_transformation_metainf.csv'), 'w') as transformation_file:
            transformation_writer = csv.DictWriter(
                transformation_file, delimiter=',', fieldnames=['seq', 'old_stamp', 'new_stamp']
            )
            transformation_writer.writeheader()
            for seq, old_stamp in enumerate(filename_timestamps):
                new_stamp = int(old_stamp) + delta
                new_name = str(new_stamp) + "." + extension
                old_name = str(old_stamp) + "." + extension
                print("Old name: %s new name: %s" % (old_name, new_name))

                transformation_writer.writerow({'seq': seq, 'old_stamp': old_stamp, 'new_stamp': new_stamp})
                os.rename(
                    os.path.join(target_dir, old_name),
                    os.path.join(target_dir, new_name)
                )
                # TODO: output csv with <seq, old_ts, new_ts>
