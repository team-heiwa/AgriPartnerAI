'use client'

import React, { useState } from 'react'

interface ReportGeneratorProps {
  onPreview: (reportId: string) => void
}

export default function ReportGenerator({ onPreview }: ReportGeneratorProps) {
  const [reportType, setReportType] = useState<'weekly' | 'monthly' | 'custom'>('weekly')
  const [selectedPeriod, setSelectedPeriod] = useState({
    start: '',
    end: ''
  })
  const [selectedCategories, setSelectedCategories] = useState<string[]>(['pest', 'disease'])
  const [includeImages, setIncludeImages] = useState(true)
  const [includeActions, setIncludeActions] = useState(true)
  const [format, setFormat] = useState<'pdf' | 'csv' | 'excel'>('pdf')

  const categories = [
    { id: 'pest', label: '害虫', icon: '🐛' },
    { id: 'disease', label: '病気', icon: '🍂' },
    { id: 'environment', label: '環境', icon: '🌦️' },
    { id: 'actions', label: 'アクション', icon: '✅' },
    { id: 'drone', label: 'ドローン', icon: '🛸' }
  ]

  const handleCategoryToggle = (categoryId: string) => {
    setSelectedCategories(prev => 
      prev.includes(categoryId) 
        ? prev.filter(id => id !== categoryId)
        : [...prev, categoryId]
    )
  }

  const handleGenerateReport = () => {
    const reportId = `report_${Date.now()}`
    console.log('Generating report:', {
      type: reportType,
      period: selectedPeriod,
      categories: selectedCategories,
      includeImages,
      includeActions,
      format
    })
    onPreview(reportId)
  }

  const getPresetDates = (type: 'weekly' | 'monthly') => {
    const end = new Date()
    const start = new Date()
    
    if (type === 'weekly') {
      start.setDate(end.getDate() - 7)
    } else {
      start.setMonth(end.getMonth() - 1)
    }
    
    return {
      start: start.toISOString().split('T')[0],
      end: end.toISOString().split('T')[0]
    }
  }

  React.useEffect(() => {
    if (reportType !== 'custom') {
      setSelectedPeriod(getPresetDates(reportType))
    }
  }, [reportType])

  return (
    <div className="space-y-6">
      <h2 className="text-lg font-semibold text-gray-800">📝 レポート生成</h2>

      {/* レポートタイプ選択 */}
      <div className="space-y-3">
        <h3 className="text-sm font-semibold text-gray-700">📅 期間選択</h3>
        <div className="flex gap-4">
          {[
            { id: 'weekly', label: '週次レポート' },
            { id: 'monthly', label: '月次レポート' },
            { id: 'custom', label: 'カスタム期間' }
          ].map((type) => (
            <button
              key={type.id}
              onClick={() => setReportType(type.id as 'weekly' | 'monthly' | 'custom')}
              className={`px-4 py-2 rounded-lg border transition-colors ${
                reportType === type.id
                  ? 'bg-blue-50 border-blue-500 text-blue-700'
                  : 'bg-white border-gray-300 text-gray-600 hover:bg-gray-50'
              }`}
            >
              {type.label}
            </button>
          ))}
        </div>
      </div>

      {/* 期間指定 */}
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            開始日
          </label>
          <input
            type="date"
            value={selectedPeriod.start}
            onChange={(e) => setSelectedPeriod(prev => ({ ...prev, start: e.target.value }))}
            disabled={reportType !== 'custom'}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            終了日
          </label>
          <input
            type="date"
            value={selectedPeriod.end}
            onChange={(e) => setSelectedPeriod(prev => ({ ...prev, end: e.target.value }))}
            disabled={reportType !== 'custom'}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100"
          />
        </div>
      </div>

      {/* カテゴリ選択 */}
      <div className="space-y-3">
        <h3 className="text-sm font-semibold text-gray-700">🏷️ 含めるカテゴリ</h3>
        <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
          {categories.map((category) => (
            <label key={category.id} className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={selectedCategories.includes(category.id)}
                onChange={() => handleCategoryToggle(category.id)}
                className="rounded"
              />
              <span className="text-sm flex items-center gap-1">
                <span>{category.icon}</span>
                <span>{category.label}</span>
              </span>
            </label>
          ))}
        </div>
      </div>

      {/* オプション設定 */}
      <div className="space-y-3">
        <h3 className="text-sm font-semibold text-gray-700">⚙️ オプション</h3>
        <div className="space-y-2">
          <label className="flex items-center gap-2 cursor-pointer">
            <input
              type="checkbox"
              checked={includeImages}
              onChange={(e) => setIncludeImages(e.target.checked)}
              className="rounded"
            />
            <span className="text-sm">📸 画像を含める</span>
          </label>
          
          <label className="flex items-center gap-2 cursor-pointer">
            <input
              type="checkbox"
              checked={includeActions}
              onChange={(e) => setIncludeActions(e.target.checked)}
              className="rounded"
            />
            <span className="text-sm">✅ アクション履歴を含める</span>
          </label>
        </div>
      </div>

      {/* 出力形式 */}
      <div className="space-y-3">
        <h3 className="text-sm font-semibold text-gray-700">📄 出力形式</h3>
        <div className="flex gap-4">
          {[
            { id: 'pdf', label: 'PDF', icon: '📄' },
            { id: 'csv', label: 'CSV', icon: '📊' },
            { id: 'excel', label: 'Excel', icon: '📈' }
          ].map((formatOption) => (
            <button
              key={formatOption.id}
              onClick={() => setFormat(formatOption.id as 'pdf' | 'csv' | 'excel')}
              className={`flex items-center gap-2 px-4 py-2 rounded-lg border transition-colors ${
                format === formatOption.id
                  ? 'bg-blue-50 border-blue-500 text-blue-700'
                  : 'bg-white border-gray-300 text-gray-600 hover:bg-gray-50'
              }`}
            >
              <span>{formatOption.icon}</span>
              <span>{formatOption.label}</span>
            </button>
          ))}
        </div>
      </div>

      {/* 生成設定サマリー */}
      <div className="bg-gray-50 rounded-lg p-4">
        <h4 className="text-sm font-semibold text-gray-700 mb-2">📋 生成設定サマリー</h4>
        <div className="text-sm text-gray-600 space-y-1">
          <div>期間: {selectedPeriod.start} 〜 {selectedPeriod.end}</div>
          <div>カテゴリ: {selectedCategories.length}件選択</div>
          <div>形式: {format.toUpperCase()}</div>
          <div>オプション: {[includeImages && '画像', includeActions && 'アクション'].filter(Boolean).join(', ')}</div>
        </div>
      </div>

      {/* 生成ボタン */}
      <div className="flex gap-4">
        <button
          onClick={handleGenerateReport}
          disabled={selectedCategories.length === 0 || !selectedPeriod.start || !selectedPeriod.end}
          className="flex-1 bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
        >
          📊 レポート生成
        </button>
        
        <button className="px-6 py-3 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors">
          💾 設定保存
        </button>
      </div>

      {/* 予想生成時間 */}
      <div className="text-xs text-gray-500 text-center">
        予想生成時間: 約 {selectedCategories.length * 30} 秒
      </div>
    </div>
  )
}