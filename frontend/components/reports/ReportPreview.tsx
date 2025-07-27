'use client'

import React from 'react'

interface ReportPreviewProps {
  reportId: string | null
}

export default function ReportPreview({ reportId }: ReportPreviewProps) {
  if (!reportId) {
    return (
      <div className="bg-white rounded-lg border border-gray-200 p-6 h-96 flex items-center justify-center">
        <div className="text-center text-gray-500">
          <span className="text-4xl block mb-2">📄</span>
          <p>レポートを選択してください</p>
          <p className="text-sm mt-1">生成またはプレビューができます</p>
        </div>
      </div>
    )
  }

  // モックプレビューデータ
  const previewData = {
    title: '週次レポート（1/8-1/14）',
    type: 'weekly',
    period: '2024年1月8日 - 2024年1月14日',
    generated: '2024年1月15日 09:30',
    summary: {
      totalCards: 18,
      highRisk: 5,
      mediumRisk: 8,
      lowRisk: 5,
      completedActions: 12,
      pendingActions: 6
    },
    sections: [
      {
        title: 'エグゼクティブサマリー',
        content: '今週は害虫リスクが高い状態が継続しています。特にカメムシの発生が東エリアで確認されており、緊急対応が必要です。'
      },
      {
        title: '害虫検出状況',
        content: '5件の害虫関連カードが作成されました。カメムシ（3件）、アブラムシ（2件）が主な検出対象です。'
      },
      {
        title: '病気検出状況', 
        content: '3件の病気関連カードが作成されました。灰色かび病の初期症状が西エリアで確認されています。'
      },
      {
        title: 'アクション実行状況',
        content: '18件のアクションが作成され、12件が完了しました。実行率67%で目標を上回っています。'
      }
    ]
  }

  return (
    <div className="bg-white rounded-lg border border-gray-200 h-full max-h-[600px] overflow-y-auto">
      {/* ヘッダー */}
      <div className="sticky top-0 bg-white border-b border-gray-200 p-4">
        <h2 className="text-lg font-semibold text-gray-800 mb-2">{previewData.title}</h2>
        <div className="text-sm text-gray-600">
          <div>📅 期間: {previewData.period}</div>
          <div>🕒 生成: {previewData.generated}</div>
        </div>
      </div>

      <div className="p-4 space-y-6">
        {/* サマリー統計 */}
        <div className="space-y-3">
          <h3 className="text-sm font-semibold text-gray-700">📊 週間サマリー</h3>
          <div className="grid grid-cols-2 gap-3">
            <div className="bg-blue-50 rounded p-3 text-center">
              <div className="text-lg font-bold text-blue-600">{previewData.summary.totalCards}</div>
              <div className="text-xs text-blue-600">総カード数</div>
            </div>
            <div className="bg-red-50 rounded p-3 text-center">
              <div className="text-lg font-bold text-red-600">{previewData.summary.highRisk}</div>
              <div className="text-xs text-red-600">高リスク</div>
            </div>
            <div className="bg-yellow-50 rounded p-3 text-center">
              <div className="text-lg font-bold text-yellow-600">{previewData.summary.mediumRisk}</div>
              <div className="text-xs text-yellow-600">中リスク</div>
            </div>
            <div className="bg-green-50 rounded p-3 text-center">
              <div className="text-lg font-bold text-green-600">{previewData.summary.lowRisk}</div>
              <div className="text-xs text-green-600">低リスク</div>
            </div>
          </div>
        </div>

        {/* アクション統計 */}
        <div className="space-y-3">
          <h3 className="text-sm font-semibold text-gray-700">✅ アクション実行状況</h3>
          <div className="bg-gray-50 rounded p-3">
            <div className="flex justify-between text-sm mb-2">
              <span>実行進捗</span>
              <span>{previewData.summary.completedActions}/{previewData.summary.completedActions + previewData.summary.pendingActions}</span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div 
                className="h-2 rounded-full bg-green-500"
                style={{ 
                  width: `${(previewData.summary.completedActions / (previewData.summary.completedActions + previewData.summary.pendingActions)) * 100}%` 
                }}
              ></div>
            </div>
            <div className="text-xs text-gray-600 mt-1">
              実行率: {Math.round((previewData.summary.completedActions / (previewData.summary.completedActions + previewData.summary.pendingActions)) * 100)}%
            </div>
          </div>
        </div>

        {/* レポートセクション */}
        <div className="space-y-4">
          <h3 className="text-sm font-semibold text-gray-700">📝 レポート内容</h3>
          {previewData.sections.map((section, index) => (
            <div key={index} className="border border-gray-200 rounded p-3">
              <h4 className="font-medium text-gray-800 mb-2">{section.title}</h4>
              <p className="text-sm text-gray-600 leading-relaxed">
                {section.content}
              </p>
            </div>
          ))}
        </div>

        {/* グラフプレビュー */}
        <div className="space-y-3">
          <h3 className="text-sm font-semibold text-gray-700">📈 トレンド分析</h3>
          <div className="bg-gray-50 rounded p-4 h-32 flex items-center justify-center">
            <div className="text-center text-gray-500">
              <span className="text-2xl block mb-1">📊</span>
              <p className="text-xs">リスクトレンドグラフ</p>
              <p className="text-xs">(PDFで表示されます)</p>
            </div>
          </div>
        </div>

        {/* 画像プレビュー */}
        <div className="space-y-3">
          <h3 className="text-sm font-semibold text-gray-700">📸 添付画像</h3>
          <div className="grid grid-cols-3 gap-2">
            {[1, 2, 3, 4, 5, 6].map((i) => (
              <div key={i} className="bg-gray-100 rounded aspect-square flex items-center justify-center">
                <span className="text-xs text-gray-500">IMG_{i}</span>
              </div>
            ))}
          </div>
          <div className="text-xs text-gray-500 text-center">
            6枚の画像が含まれます
          </div>
        </div>

        {/* 推奨アクション */}
        <div className="space-y-3">
          <h3 className="text-sm font-semibold text-gray-700">💡 AI推奨アクション</h3>
          <div className="space-y-2">
            {[
              '東エリアのカメムシ対策を優先実施',
              '西エリアの換気システム点検',
              '湿度管理の強化（目標：85%以下）',
              '予防的薬剤散布スケジュールの見直し'
            ].map((action, index) => (
              <div key={index} className="flex items-center gap-2 text-sm">
                <span className="text-blue-600">•</span>
                <span className="text-gray-700">{action}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* アクションボタン */}
      <div className="sticky bottom-0 bg-white border-t border-gray-200 p-4">
        <div className="flex gap-2">
          <button className="flex-1 bg-blue-600 text-white px-3 py-2 rounded text-sm hover:bg-blue-700 transition-colors">
            📥 ダウンロード
          </button>
          <button className="flex-1 bg-green-600 text-white px-3 py-2 rounded text-sm hover:bg-green-700 transition-colors">
            📧 メール送信
          </button>
          <button className="px-3 py-2 border border-gray-300 rounded text-sm hover:bg-gray-50 transition-colors">
            📝 編集
          </button>
        </div>
      </div>
    </div>
  )
}