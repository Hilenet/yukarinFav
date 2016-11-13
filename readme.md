# yukarinFav
## about
TLに流れてくるゆかりさんをふぁぼる


## usage
1. mecab入れて．パス通す．
2. mecab-ipadic-neologd入れて形式変換，mecabにユーザ辞書として認識させる．やらなくても良いけど精度が段違い．
3. このリポジトリをclone．
4. Twitterのoauth情報をprof.yamlに保存．
5. 多分これで動く．
``` yaml
cred:
  consumer:
    key: <Consumer_key>
    secret: <consumer_secret>
  access_token:
    key: <access_token>
    secret: <access_token_secret>

```


## release note
### v0.1


取り敢えず動く
1. user_streamからツイートを取得し，テキストをmecabでパース
  * RT，replyは除外
2. 品詞「ゆかり」を含むツイートを抽出
  * 特定ワードとユーザーのリストをコードに直書き，該当すれば除外
3. 各品詞を評価し，スコアが0を上回ったらふぁぼ


## methods
### parse
* 形態素解析エンジン[mecab](http://taku910.github.io/mecab)
* mecabの新語・固有表現辞書[mecab-ipadic-neologd](https://github.com/neologd/mecab-ipadic-neologd)

mecabにユーザ辞書としてmecab-ipadic-neologdを設定．
gen `natto`を使ってスクリプト中から呼び出し，パース.


### evaluate
* [単語感情極性対応表](http://www.lr.pi.titech.ac.jp/~takamura/pndic_ja.html)

パースした各単語を対応表に照らし合わせてスコアリング．


## overlook
* スコアリング精度の向上
  * 係り受け解析に基づき「ゆかり」に関係する品詞のみ評価
* 「ゆかり」以外の表記に対応
  * 「ゆっかりーん」「ゆか**」など
* ゆかりさんの画像を学習
  * mattu_nya氏に依頼中
