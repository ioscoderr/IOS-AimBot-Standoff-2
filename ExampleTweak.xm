#import "Macros.h"
#import "Vector3.h"
#import "Quaternion.h"
#import "Macros.h"
#include <cmath>

float NormalizeAngle (float angle){
    while (angle>360)
        angle -= 360;
    while (angle<0)
        angle += 360;
    return angle;
}

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
    v.y = atan2f (2.0f * q.x * q.w + 2.0f * q.y * q.z, 1 - 2.0f * (q.z * q.z + q.w * q.w)); // yaw
    v.x = asinf (2.0f * (q.x * q.z - q.w * q.y)); // pitch
    v.z = atan2f (2.0f * q.x * q.y + 2.0f * q.z * q.w, 1 - 2.0f * (q.y * q.y + q.z * q.z)); // roll
    return NormalizeAngles (v * Rad2Deg);
}

void *(*get_transform)(void *);
Vector3 (*get_position)(void *);
int (*GetTeam)(void *);
int (*GetHealth)(void *);
bool (*get_IsLocal)(void *);

struct me_t
{
    void *object;
    Vector3 position;
    float fov;
}*me;

struct enemy_t
{
    void *object;
    Vector3 position;
    Vector3 w2sposition;
    int health;
    void *biped;
    Vector3 headposition;
    void *head;
}*enemy;

Vector3 GetObjectLocation(void *object)
{
    return get_position(get_transform(object));
}

void (*old_player_update)(void *player);
void new_player_update(void *player)
{
    void *aimcontroller = *(void **)((uint64_t)player + 0x60);
    void *aimingdata = *(void **)((uint64_t)aimcontroller + 0x90);
    
    if (get_IsLocal(player))
    {
        me->object = player;
        me->position = GetObjectLocation(me->object);
    }

    if (me->object)
    {
        if (GetTeam(me->object) != GetTeam(player))
        {
            enemy->object = player;
            enemy->health = GetHealth(enemy->object);
            enemy->position = GetObjectLocation(enemy->object);
            enemy->biped = *(void **)((uint64_t)enemy->object + 0x30);
            enemy->head = *(void **)((uint64_t)enemy->biped + 0x18);
            enemy->headposition = GetObjectLocation(enemy->head);
        }

        if ([switches isSwitchOn:@"Aimbot"] /* && enemy->visible */)
        {
            Quaternion rotation = Quaternion::LookRotation(enemy->position - me->position);
            if (aimingdata && enemy->health > 0)
            {
                Vector3 angle = ToEulerRad(rotation);
                *(Vector3 *)((uint64_t)aimingdata + 0x18) = angle;
                *(Vector3 *)((uint64_t)aimingdata + 0x24) = angle;
            }
        }  
    }
    old_player_update(player);
}

void setup()
{
    me = new me_t();
    enemy = new enemy_t();

    HOOK(0x1B005B8, new_player_update, old_player_update);

    *(void **)&get_transform = (void *)getRealOffset(0x3485CA4); //0.24.3xd)
    *(void **)&get_position = (void *)getRealOffset(0x348F83C); //0.24.3(xd)
    *(void **)&GetTeam = (void *)getRealOffset(0x1B01720); //0.24.3(xd)
    *(void **)&GetHealth = (void *)getRealOffset(0x1B00D80); //0.24.3(xd)
    *(void **)&get_IsLocal = (void *)getRealOffset(0x1AFE00C); //0.24.3(xd)

    [switches addSwitch:@"Aimbot" description:nil];
}

void setupMenu() {

    [menu setFrameworkName:"UnityFramework"];
    menu = [[Menu alloc]  
        initWithTitle:@"unknown shit"
        titleColor:[UIColor whiteColor]
        titleFont:@"Helvetica-Bold"
        credits:@"This code has been written by Sier.\n\nEnjoy!"
        headerColor:UIColorFromHex(0x343642)
        switchOffColor:[UIColor clearColor]
        switchOnColor:UIColorFromHex(0x343642)
        switchTitleFont:@"Helvetica-Bold"
        switchTitleColor:[UIColor whiteColor]
        infoButtonColor:UIColorFromHex(0x343642)
        maxVisibleSwitches:6
        menuWidth:235
        menuIcon:@""
        menuButton:@""];

    setup();
}

static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
    timer(1) {
        setupMenu();
    });
}


%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}