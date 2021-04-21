# Copyright 2020 Mobile Robotics Lab. at Skoltech
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
from src.alignment_utils import align_by_ref, align_by_delta, align_csv

ALIGN_BY_REF = 'ref'
ALIGN_BY_DELTA = 'delta'
ALIGN_CSV = 'csv'
ALIGN_FLASH = 'flash'

FLASH_SUFFIX = 'flash'
FRAME_SUFFIX = 'timestamps'


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
        choices=[ALIGN_BY_DELTA, ALIGN_BY_REF, ALIGN_CSV, ALIGN_FLASH],
        help='<Required> Alignment type',
        required=True
    )
    parser.add_argument(
        "--ref_seq",
        type=int,
        required=False
    )
    parser.add_argument(
        "--vid",
        required=False
    )


    args = parser.parse_args()
    time_ref_file = args.time_ref_file.name
    target_dir = args.target_dir
    if args.align_type == ALIGN_BY_REF:
        ref_seq = args.ref_seq
        align_by_ref(time_ref_file, target_dir, ref_seq)
    elif args.align_type == ALIGN_BY_DELTA:
        align_by_delta(time_ref_file, target_dir)
    elif args.align_type == ALIGN_CSV:
        align_csv(time_ref_file, target_dir, args.vid, FRAME_SUFFIX)
    elif args.align_type == ALIGN_FLASH:
        align_csv(time_ref_file, target_dir, args.vid, FLASH_SUFFIX)


if __name__ == '__main__':
    main()
