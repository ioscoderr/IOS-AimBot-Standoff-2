float NormalizeAngle (float angle){
    while (angle>360)
        angle -= 360;
    while (angle<0)
        angle += 360;
    return angle;
}

//https://t.me/andrdevvv
//https://t.me/andrdevvv
//https://t.me/andrdevvv

Vector3 NormalizeAngles (Vector3 angles){
    angles.x = NormalizeAngle (angles.x);
    angles.y = NormalizeAngle (angles.y);
    angles.z = NormalizeAngle (angles.z);
    return angles;
}


Vector3 ToEulerRad(Quaternion q1){
    float Rad2Deg = 360.0f / (M_PI * 2.0f);

    float sqw = q1.w * q1.w;
    float sqx = q1.x * q1.x;
    float sqy = q1.y * q1.y;
    float sqz = q1.z * q1.z;
    float unit = sqx + sqy + sqz + sqw;
    float test = q1.x * q1.w - q1.y * q1.z;
    Vector3 v;

    if (test>0.4995f*unit) {
        v.y = 2.0f * atan2f (q1.y, q1.x);
        v.x = M_PI / 2.0f;
        v.z = 0;
        return NormalizeAngles(v * Rad2Deg);
    }
    if (test<-0.4995f*unit) {
        v.y = -2.0f * atan2f (q1.y, q1.x);
        v.x = -M_PI / 2.0f;
        v.z = 0;
        return NormalizeAngles (v * Rad2Deg);
    }
    Quaternion q(q1.w, q1.z, q1.x, q1.y);
    v.y = atan2f (2.0f * q.x * q.w + 2.0f * q.y * q.z, 1 - 2.0f * (q.z * q.z + q.w * q.w));     v.x = asinf (2.0f * (q.x * q.z - q.w * q.y));
    v.z = atan2f (2.0f * q.x * q.y + 2.0f * q.z * q.w, 1 - 2.0f * (q.y * q.y + q.z * q.z));
    return NormalizeAngles (v * Rad2Deg);
}

//https://t.me/andrdevvv
//https://t.me/andrdevvv
//https://t.me/andrdevvv


void *aimcontroller = *(void **)((uint64_t)player + 0x60);
void *aimingdata = *(void **)((uint64_t)aimcontroller + 0x90);

//https://t.me/andrdevvv
//https://t.me/andrdevvv
//https://t.me/andrdevvv


if ([switches isSwitchOn:@"AimBot"])
{
    Quaternion rotation = Quaternion::LookRotation(enemy->position - me->position);
    if (aimingdata && enemy->health > 0)
    {
        Vector3 angle = ToEulerRad(rotation);
        *(Vector3 *)((uint64_t)aimingdata + 0x18) = angle;
        *(Vector3 *)((uint64_t)aimingdata + 0x24) = angle;
    }
}

//https://t.me/andrdevvv
//https://t.me/andrdevvv
//https://t.me/andrdevvv
