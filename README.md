# iOS AIMBot Template for Theos(Standoff 2)!


<br>


###Installation in Tweak.xm:

**Tweak.xm**



**Add aimbot code**
Lines 1-45 (NormalizeAngle, NormalizeAngles, ToEulerRad) add to the beginning of your file **Tweak.xm**, make sure you have structures me_t and enemy_t, then add to hook void player_update:

```obj-c
void *aimcontroller = *(void **)((uint64_t)player + 0x60);
void *aimingdata = *(void **)((uint64_t)aimcontroller + 0x90);
```


I'm doing it on the example of iOS ted menu.

Add a check that the switch is turned on:

```obj-c
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
```

### Credits:
* [andrdev](https://t.me/andrdevvv)


