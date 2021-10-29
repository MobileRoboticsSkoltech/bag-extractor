import pandas as pd
from collections import deque
import sys


def addExtension(tVal):
    return str(tVal) + ".png"


if __name__ == '__main__':
    dataDir = sys.argv[1]
    timestampPath = sys.argv[2]
    gyroPath = sys.argv[3]

    # ----------#

    timestampLabels = ["#timestamp [μs]", "filename"]
    timestamps = pd.read_csv(timestampPath, header=None, dtype=str)
    outputFilename = dataDir + "/timestamps.csv"

    data = {
        timestampLabels[0]: timestamps[0], timestampLabels[1]: timestamps[0] + ".png"
    }

    dataframe = pd.DataFrame(data=data)
    dataframe.to_csv(outputFilename, sep='\t', encoding='utf-8', index=False)

    # ----------#

    imuLabels = [
        "#timestamp [μs]",
        "w_RS_S_x [rad s^-1]",
        "w_RS_S_y [rad s^-1]",
        "w_RS_S_z [rad s^-1]",
        "a_RS_S_x [m s^-2]",
        "a_RS_S_y [m s^-2]",
        "a_RS_S_z [m s^-2]"
    ]

    gyro = pd.read_csv(gyroPath, header=None)
    outputFilename = dataDir + "/gyro_accel.csv"

    if len(sys.argv) == 5:
        accelPath = sys.argv[4]
        accel = pd.read_csv(accelPath, header=None)

        tempVal = 0
        index = 0
        counter = 0

        accelX = deque()
        accelY = deque()
        accelZ = deque()

        for indexGyro, rowGyro in gyro.iterrows():
            for i in range(index, len(gyro)):
                if gyro.loc[i, 3] > rowGyro[0]:
                    index = i + 1

                    accelX.append(gyro.loc[i, 0])
                    accelY.append(gyro.loc[i, 1])
                    accelZ.append(gyro.loc[i, 2])

                    break

        data = {
            imuLabels[0]: gyro[3],
            imuLabels[1]: gyro[0],
            imuLabels[2]: gyro[1],
            imuLabels[3]: gyro[2],
            imuLabels[4]: accelX,
            imuLabels[5]: accelY,
            imuLabels[6]: accelZ
        }
    else:
        data = {
            imuLabels[0]: gyro[3],
            imuLabels[1]: gyro[0],
            imuLabels[2]: gyro[1],
            imuLabels[3]: gyro[2],
            imuLabels[4]: "",
            imuLabels[5]: "",
            imuLabels[6]: ""
        }

    dataframe = pd.DataFrame(data=data)
    dataframe.to_csv(outputFilename, sep='\t', encoding='utf-8', index=False)

