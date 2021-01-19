import argparse
from src.alignment_utils import align


def main():
    parser = argparse.ArgumentParser(
        description="Align extracted data timestamps"
    )
    parser.add_argument(
        "--time_ref_file",
        type=argparse.FileType(mode='r'),
        required=True
    )
    parser.add_argument(
        "--target_dir",
        required=True
    )
    parser.add_argument(
        "--ref_seq",
        type=int,
        required=True
    )

    args = parser.parse_args()
    time_ref_file = args.time_ref_file.name
    target_dir = args.target_dir
    ref_seq = args.ref_seq
    align(time_ref_file, target_dir, ref_seq)


if __name__ == '__main__':
    main()