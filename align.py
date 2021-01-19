import argparse
from src.alignment_utils import align_by_ref, align_by_delta

ALIGN_BY_REF = 'ref'
ALIGN_BY_DELTA = 'delta'


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
        "--align_type",
        choices=[ALIGN_BY_DELTA, ALIGN_BY_REF],
        help='<Required> Alignment type',
        required=True
    )
    parser.add_argument(
        "--ref_seq",
        type=int,
        required=False
    )
    parser.add_argument(
        "--video_date",
        required=False
    )

    args = parser.parse_args()
    time_ref_file = args.time_ref_file.name
    target_dir = args.target_dir
    if args.align_type == ALIGN_BY_REF:
        ref_seq = args.ref_seq
        align_by_ref(time_ref_file, target_dir, ref_seq)
    else:
        video_date = args.video_date
        align_by_delta(time_ref_file, target_dir, video_date)


if __name__ == '__main__':
    main()