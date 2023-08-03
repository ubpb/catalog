import { Controller } from "@hotwired/stimulus"
import noUiSlider from "nouislider"
import Chart from "chart.js/auto"

export default class extends Controller {
  static targets = [
    "chart", "slider", "lowerOutput", "upperOutput"
  ]

  static values = {
    url: String,
    lower: Number,
    upper: Number,
    chartData: Array
  }

  connect() {
    let that = this

    this.selectedLowerValue = this.lowerValue
    this.selectedUpperValue = this.upperValue

    noUiSlider.create(this.sliderTarget, {
      start: [this.lowerValue, this.upperValue],
      connect: true,
      step: 1,
      range: {
        'min': this.lowerValue,
        'max': this.upperValue
      }
    })

    this.sliderTarget.noUiSlider.on("update", function (values, handle, unencoded) {
        // "values" has the "to" function from "format" applied
        // "unencoded" contains the raw numerical slider values
        if (handle == 0) {
          that.selectedLowerValue = Math.round(unencoded[0])
          that.lowerOutputTarget.innerHTML = that.selectedLowerValue
        } else if (handle == 1) {
          that.selectedUpperValue = Math.round(unencoded[1])
          that.upperOutputTarget.innerHTML = that.selectedUpperValue
        }
    })

    new Chart(this.chartTarget, {
      type: 'bar',
      data: {
        datasets: [{
          label: false,
          data: this.chartDataValue,
          backgroundColor: '#50D1D1',
          borderRadius: 2
        }]
      },
      options: {
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            enabled: false,
            callbacks: {
            }
          }
        },
        scales: {
          x: {
            grid: {
              display: false,
              borderColor: '#ccc'
            },
            ticks: {
              display: false
            }
          },
          y: {
            display: false
          }
        }
      }
    })
  }

  setAggregation() {
    window.location = this.urlValue
      .replace("MIN", this.selectedLowerValue)
      .replace("MAX", this.selectedUpperValue)
  }

}
