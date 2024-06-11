游戏应用作为App中特殊的一类，需要从系统获取信息，也需要借助系统API实现游戏特有的一些功能，例如登录、支付、防沉迷、实名认证等。

HarmonyOS专门为游戏类应用提供了Game Service Kit（基础游戏服务），用于
提供游戏相关的基础能力。

基于Game Service Kit，我们可以实现华为登录、获取玩家信息、获取玩家角色、保存玩家角色等功能。

## 1. 登录
登录功能需要要使用华为帐号应用统一认证服务（Account Kit）。
首先，需要导入`authentication`:

```ts
import { authentication } from '@kit.AccountKit';
```

再创建登录请求：

```ts
// 创建登录请求，并设置参数
    let loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
    // 当用户未登录华为帐号时，是否强制拉起华为帐号登录界面
    loginRequest.forceLogin = true;
    loginRequest.state = util.generateRandomUUID();
```

最后，执行登录请求，即可在回调中获取登录信息：

```ts
// 执行登录请求
    try {
      let controller = new authentication.AuthenticationController(getContext(this) as common.UIAbilityContext);
      controller.executeRequest(loginRequest, (err, data) => {
        if (err) {
          this.logText = "login failed:" +  JSON.stringify(err);
          hilog.error(0x0000, 'testTag', 'login fail, error: %{public}s', JSON.stringify(err));
          return;
        }
        let loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
        let state = loginWithHuaweiIDResponse.state;
        if (state != undefined && loginRequest.state != state) {
          this.logText = "login failed:" + JSON.stringify(loginWithHuaweiIDResponse)
          hilog.error(0x0000, 'testTag', 'login fail,The state is different: %{public}s', JSON.stringify(loginWithHuaweiIDResponse));
          return;
        }
        this.logText = "login success:" + JSON.stringify(loginWithHuaweiIDResponse)
        hilog.debug(0x0000, 'testTag', 'login success, %{public}s', JSON.stringify(loginWithHuaweiIDResponse));

        let loginWithHuaweiIDCredential = loginWithHuaweiIDResponse.data!;
        let tokenCode = loginWithHuaweiIDCredential.authorizationCode; // 登录token
        let idToken = loginWithHuaweiIDCredential.idToken; // JWT
        let openId = loginWithHuaweiIDCredential.openID; // Open ID, 跟随App
        let unionId = loginWithHuaweiIDCredential.unionID; // Union ID，跟随华为ID

        hilog.info(0x0000, 'gameService', '【华为登录返回】\n登录token: %{public}s, JWT令牌%{public}s, Open ID: %{public}s, Union ID: %{public}s', tokenCode, idToken, openId, unionId);
        
        // 开发者处理code, idToken, openID, unionID
      });
    } catch (e) {
      this.logText = "login failed:" + JSON.stringify(e)
      hilog.error(0x0000, 'testTag', 'login failed: %{public}s', JSON.stringify(e));
    }
```

这里使用try-catch捕获异常，在登录请求的回调中，我们获取`loginWithHuaweiIDResponse.data`用于创建账号或执行游戏平台登录。
其中`loginWithHuaweiIDResponse.data`的类型是`LoginWithHuaweiIDCredential`，其属性参数包括：
* authorizationCode: 登录token，用于登录验证。
* idToken: JSON Web令牌（JWT），确保将用户信息安全传输到应用程序。
* openID: 唯一ID，与华为ID关联，随用户使用的应用程序而异。
* unionID: 保持不变的唯一ID，与华为帐号关联，用户同一账号下的所有App的unionID不变。

## 获取玩家信息
这一能力的使用需要导入`gamePlayer`：

```ts
import { gamePlayer } from '@kit.GameServiceKit';
```

在`init()`中通过上下文初始化`gamePlayer`：

```ts
init(){
    let context = getContext(this) as common.UIAbilityContext;
    gamePlayer.init(context, () => {
      this.logText = "init success."
      console.log('init success.');
    });
  }
```

通过`common.UIAbilityContext`可以获取`gamePlayer`信息：

```ts
 getPlayer(){
    let context = getContext(this) as common.UIAbilityContext;
    gamePlayer.getLocalPlayer(context, (error, result) => {
    if (error) {
        this.logText = 'getLocalPlayer failed:' + JSON.stringify(error)
        console.error('getLocalPlayer failed:' + JSON.stringify(error));
        return;
      }
      this.logText = 'getLocalPlayer success:' + JSON.stringify(result)
      console.log('getLocalPlayer success:' + JSON.stringify(result))


      let gamePlayerId = result.gamePlayerId; // 玩家ID
      let teamPlayerId = result.teamPlayerId; // 与开发者账号关联的玩家ID
      let idCompatibleType = result.idCompatibleType; // ID关联类型：0-不兼容 1-与playerId关联 2-与OpenId关联 3-与gamePlayerId关联
      let level = result.level; // GameCenter中的玩家消费权限级别。
      let playableTime = result.playableTime; // 玩家这次的可玩时长（单位：分钟）
      
    });
  }
```

## 保存玩家角色

`gamePlayer`支持创建请求，保存玩家角色信息到游戏服务器。角色信息包含`roleId`、`roleName`、`serverId`、`serverName`、`gamePlayerId`、`teamPlayerId`等.

```ts
saveRole(){
    let context = getContext(this) as common.UIAbilityContext;
    let request: gamePlayer.GSKPlayerRole = {
      roleId: '890765478',   //玩家角色ID，务必不要传""和null。如游戏没有角色系统，请传入“0”。
      roleName: '爱吃竹子的小胖达', //玩家角色名，务必不要传""和null。如游戏没有角色系统，请传入“default”。
      serverId: '98765789',
      serverName: 'huazhong-1',
      gamePlayerId: '9817678392',
      teamPlayerId: '6718976541'
    };
    gamePlayer.savePlayerRole(context, request, () => {
      this.logText = "savePlayerRole success."
      console.log('savePlayerRole success.');
    });
  }
```

这里的游戏服务器是指华为游戏服务器，Game Service Kit同时支持REST API[获取玩家标识](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/gameservice-getplayerinfo-0000001743469302#section1798515114357)，可以通过Server to Server API对已经获得的Access Token进行鉴权。

至此，Game Service Kit提供的基础功能就介绍完了，作为游戏应用开发者，我们可能还会关注支付、广告、归因等方面功能，相信HarmonyOS也会尽快跟进，就让我们拭目以待吧。
