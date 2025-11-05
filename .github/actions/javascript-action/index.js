/**
 * JavaScript Custom Action 範例
 * 
 * 這個 Action 示範了：
 * 1. 如何接收輸入參數
 * 2. 如何設定輸出結果
 * 3. 如何使用 GitHub Actions Toolkit
 * 4. 如何進行錯誤處理
 */

const core = require('@actions/core');
const github = require('@actions/github');

async function run() {
  try {
    // 1. 取得輸入參數
    const nameToGreet = core.getInput('who_to_greet');
    const messagePrefix = core.getInput('message_prefix');
    
    // 2. 執行主要邏輯
    console.log(`🎉 開始執行 JavaScript Action...`);
    
    const time = new Date().toTimeString();
    const greetingMessage = `${messagePrefix} ${nameToGreet}!`;
    
    // 3. 記錄訊息
    core.info(`問候訊息: ${greetingMessage}`);
    core.info(`執行時間: ${time}`);
    
    // 4. 設定輸出
    core.setOutput('time', time);
    core.setOutput('greeting-message', greetingMessage);
    
    // 5. 取得 GitHub 上下文資訊
    const context = github.context;
    console.log(`📦 倉庫: ${context.repo.owner}/${context.repo.repo}`);
    console.log(`🔀 事件名稱: ${context.eventName}`);
    
    if (context.payload.pull_request) {
      console.log(`🔗 PR 編號: ${context.payload.pull_request.number}`);
    }
    
    // 6. 顯示成功訊息
    core.notice(`✅ Action 執行成功！問候 ${nameToGreet}`);
    
    // 7. 設定環境變數 (供後續步驟使用)
    core.exportVariable('CUSTOM_GREETING', greetingMessage);
    
    // 8. 添加摘要 (顯示在 workflow 執行摘要中)
    await core.summary
      .addHeading('JavaScript Action 執行結果')
      .addTable([
        [{data: '項目', header: true}, {data: '值', header: true}],
        ['問候對象', nameToGreet],
        ['訊息前綴', messagePrefix],
        ['完整訊息', greetingMessage],
        ['執行時間', time]
      ])
      .write();
    
  } catch (error) {
    // 錯誤處理
    core.setFailed(`❌ Action 執行失敗: ${error.message}`);
  }
}

// 執行主函式
run();
